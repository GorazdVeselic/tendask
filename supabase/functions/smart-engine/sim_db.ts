// A stateful stand-in for the supabase client, for the 365-day season
// simulation (season_sim_test.ts). FakeDb answers every select from a fixed
// `rows` map and only records writes — enough for a single run, useless across
// days: cooldowns, mutes and cross-run dedup all live in rows the engine WRITES
// and re-READS on a later run. A simulation on top of FakeDb would measure how
// often a rule *can* fire, not how often it does.
//
// So: writes land in the same store selects read from, upserts merge (PostgREST
// keeps columns the payload omits — the mute-survives-emit gotcha in
// docs/m11/04 §4.3), and updates hit exactly the filtered rows.
// deno-lint-ignore-file no-explicit-any

export type Row = Record<string, any>;

export interface Write {
  table: string;
  op: 'insert' | 'update' | 'upsert';
  payload: any;
}

/** Columns Postgres fills on INSERT that the engine relies on when it reads the
 * row back (housekeeping reads status/dismiss_scope/updated_at/deleted). */
const kInsertDefaults: Record<string, Row> = {
  suggestion: { status: 'new', dismiss_scope: 'season', deleted: false },
};

/** ON CONFLICT target per table, mirroring the real unique constraints. */
const kConflictKeys: Record<string, string[]> = {
  suggestion_log: ['user_id', 'guard_key', 'subject_key'],
  engine_run: ['user_id'],
  weather_cache: ['h3_r7', 'date'],
  profile: ['user_id'],
};

export class SimDb {
  rows: Record<string, Row[]> = {};
  writes: Write[] = [];
  /** Stands in for Postgres `default now()` on inserted rows. */
  now = new Date(0);

  from(table: string): SimQuery {
    return new SimQuery(this, table);
  }

  table(name: string): Row[] {
    const rows = this.rows[name];
    if (rows) return rows;
    const fresh: Row[] = [];
    this.rows[name] = fresh;
    return fresh;
  }
}

type Filter = (row: Row) => boolean;

class SimQuery implements PromiseLike<{ data: any; error: any }> {
  constructor(private db: SimDb, private tableName: string) {}

  private op: 'select' | 'insert' | 'update' | 'upsert' = 'select';
  private payload: any;
  private filters: Filter[] = [];
  private single = false;
  private orderBy: { column: string; ascending: boolean } | null = null;
  private limitN: number | null = null;

  select(_columns?: string): this {
    return this;
  }
  insert(values: any): this {
    this.op = 'insert';
    this.payload = values;
    return this;
  }
  update(values: any): this {
    this.op = 'update';
    this.payload = values;
    return this;
  }
  upsert(values: any, _opts?: unknown): this {
    this.op = 'upsert';
    this.payload = values;
    return this;
  }
  eq(column: string, value: unknown): this {
    // `task_subject.deleted` & co. filter an EMBEDDED resource, not this table —
    // treating them as a column filter would drop every row.
    if (!column.includes('.')) this.filters.push((r) => r[column] === value);
    return this;
  }
  in(column: string, values: unknown[]): this {
    const set = new Set(values);
    this.filters.push((r) => set.has(r[column]));
    return this;
  }
  /** The only `or` the engine issues is the task window (waiting OR recently
   * done). The simulation's task rows all satisfy it, so parsing PostgREST
   * filter syntax would buy nothing — but a NEW or() would silently widen the
   * result set, hence the throw. */
  or(filter: string): this {
    if (!filter.startsWith('status.eq.waiting')) {
      throw new Error(`SimDb.or: unsupported filter ${filter}`);
    }
    return this;
  }
  order(column: string, opts?: { ascending?: boolean }): this {
    this.orderBy = { column, ascending: opts?.ascending ?? true };
    return this;
  }
  limit(n: number): this {
    this.limitN = n;
    return this;
  }
  maybeSingle(): this {
    this.single = true;
    return this;
  }

  then<R1 = { data: any; error: any }, R2 = never>(
    onfulfilled?: ((value: { data: any; error: any }) => R1 | PromiseLike<R1>) | null,
    onrejected?: ((reason: unknown) => R2 | PromiseLike<R2>) | null,
  ): PromiseLike<R1 | R2> {
    return Promise.resolve(this.run()).then(onfulfilled, onrejected);
  }

  private matches(row: Row): boolean {
    return this.filters.every((f) => f(row));
  }

  private run(): { data: any; error: any } {
    const rows = this.db.table(this.tableName);
    if (this.op === 'select') return this.runSelect(rows);
    this.db.writes.push({ table: this.tableName, op: this.op, payload: this.payload });
    if (this.op === 'insert') this.runInsert(rows);
    else if (this.op === 'update') this.runUpdate(rows);
    else this.runUpsert(rows);
    return { data: null, error: null };
  }

  private runSelect(rows: Row[]): { data: any; error: any } {
    let out = rows.filter((r) => this.matches(r));
    const order = this.orderBy;
    if (order) {
      out = [...out].sort((a, b) => {
        const av = a[order.column] ?? '';
        const bv = b[order.column] ?? '';
        const cmp = av < bv ? -1 : av > bv ? 1 : 0;
        return order.ascending ? cmp : -cmp;
      });
    }
    if (this.limitN != null) out = out.slice(0, this.limitN);
    return { data: this.single ? out[0] ?? null : out, error: null };
  }

  private runInsert(rows: Row[]): void {
    const defaults = kInsertDefaults[this.tableName] ?? {};
    const stamped = { updated_at: this.db.now.toISOString() };
    for (const row of [this.payload].flat()) {
      rows.push({ ...defaults, ...stamped, ...row });
    }
  }

  private runUpdate(rows: Row[]): void {
    for (const row of rows) {
      if (this.matches(row)) Object.assign(row, this.payload);
    }
  }

  private runUpsert(rows: Row[]): void {
    const keys = kConflictKeys[this.tableName];
    if (!keys) throw new Error(`SimDb.upsert: no conflict key for ${this.tableName}`);
    for (const row of [this.payload].flat()) {
      const existing = rows.find((r) => keys.every((k) => r[k] === row[k]));
      // Merge, never replace: `emit` upserts a log row without dismissed_until
      // and a prior mute has to survive it (docs/m11/04 §4.3).
      if (existing) Object.assign(existing, row);
      else rows.push({ updated_at: this.db.now.toISOString(), ...row });
    }
  }
}
