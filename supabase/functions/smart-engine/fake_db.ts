// A stand-in for the supabase client, good enough for the engine's query
// shapes: every builder method chains, and awaiting runs the "query". Reads come
// from `rows[table]`, writes are recorded so a test can assert the exact payload
// (e.g. that clearing a dead FCM token never carries updated_at).
// deno-lint-ignore-file no-explicit-any

export type Row = Record<string, any>;

export interface Write {
  table: string;
  op: 'insert' | 'update' | 'upsert';
  payload: any;
}

export class FakeDb {
  /** Rows each table returns for a select, in order. */
  rows: Record<string, Row[]> = {};
  /** Every write the engine attempted, in order. */
  writes: Write[] = [];
  /** Tables whose next select must fail, to drive the error paths. */
  failOn = new Set<string>();

  from(table: string): FakeQuery {
    return new FakeQuery(this, table);
  }

  writesTo(table: string): Write[] {
    return this.writes.filter((w) => w.table === table);
  }
}

class FakeQuery implements PromiseLike<{ data: any; error: any }> {
  constructor(private db: FakeDb, private table: string) {}

  private op: 'select' | 'insert' | 'update' | 'upsert' = 'select';
  private payload: any;
  private single = false;

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
  eq(_column: string, _value: unknown): this {
    return this;
  }
  in(_column: string, _values: unknown[]): this {
    return this;
  }
  or(_filter: string): this {
    return this;
  }
  order(_column: string, _opts?: unknown): this {
    return this;
  }
  limit(_n: number): this {
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

  private run(): { data: any; error: any } {
    if (this.db.failOn.has(this.table)) {
      return { data: null, error: { message: `fake failure on ${this.table}` } };
    }
    if (this.op !== 'select') {
      this.db.writes.push({ table: this.table, op: this.op, payload: this.payload });
      return { data: null, error: null };
    }
    const rows = this.db.rows[this.table] ?? [];
    return { data: this.single ? rows[0] ?? null : rows, error: null };
  }
}
