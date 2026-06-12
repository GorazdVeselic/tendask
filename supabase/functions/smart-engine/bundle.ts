// loadUserBundle — one round of reads per user (docs/m11/03 §Cevovod step 1).
// Child rows (subjects/reminders/supplies) come embedded in the task query so
// the row count stays bounded by the task limit.

// deno-lint-ignore-file no-explicit-any
import type { TaskRow, TaskTypeMeta, UserBundle } from './types.ts';

function throwIfError(...results: { error: unknown }[]): void {
  for (const r of results) {
    if (r.error) throw r.error;
  }
}

export async function loadTaskTypes(db: any): Promise<Map<string, TaskTypeMeta>> {
  const res = await db
    .from('task_type')
    .select('id,default_cadence,weather_sensitive,seasonal');
  throwIfError(res);
  return new Map((res.data ?? []).map((t: TaskTypeMeta) => [t.id, t]));
}

export async function loadUserBundle(
  db: any,
  userId: string,
  nowUtc: Date,
): Promise<UserBundle | null> {
  const profileRes = await db
    .from('profile')
    .select('user_id,h3_r7,timezone,lang,climate_bucket,climate_profile,fcm_token')
    .eq('user_id', userId)
    .maybeSingle();
  throwIfError(profileRes);
  if (!profileRes.data) return null;

  const doneSince = new Date(nowUtc);
  doneSince.setUTCMonth(doneSince.getUTCMonth() - 24);

  const [areasRes, plantsRes, tasksRes, suppliesRes, logRes, suggestionsRes] = await Promise.all([
    db.from('area')
      .select('id,name,type,protected')
      .eq('user_id', userId).eq('deleted', false),
    db.from('user_plant')
      .select('id,area_id,plant_id,custom_name,personal_alias,is_custom,plant(category)')
      .eq('user_id', userId).eq('deleted', false),
    db.from('task')
      .select(
        'id,task_type_id,date,status,' +
          'task_subject(user_plant_id,area_id),task_reminder(id),task_supply(supply_id)',
      )
      .eq('user_id', userId).eq('deleted', false)
      .or(`status.eq.waiting,and(status.eq.done,date.gte.${doneSince.toISOString()})`)
      .eq('task_subject.deleted', false)
      .eq('task_reminder.deleted', false)
      .eq('task_supply.deleted', false)
      // PostgREST caps at max_rows (1000) — newest first keeps the recent history.
      .order('date', { ascending: false })
      .limit(1000),
    db.from('supply')
      .select('id,name,quantity,low_threshold')
      .eq('user_id', userId).eq('deleted', false),
    db.from('suggestion_log')
      .select('guard_key,subject_key,last_suggested_at,dismissed_until')
      .eq('user_id', userId)
      // No retention exists for suggestion_log — keep the newest mutes if a
      // power user ever crosses the PostgREST max_rows cap.
      .order('updated_at', { ascending: false })
      .limit(1000),
    db.from('suggestion')
      .select('task_type_id,subject_key,valid_until')
      .eq('user_id', userId).eq('status', 'new').eq('deleted', false),
  ]);
  throwIfError(areasRes, plantsRes, tasksRes, suppliesRes, logRes, suggestionsRes);

  const tasks: TaskRow[] = (tasksRes.data ?? []).map((r: any) => ({
    id: r.id,
    task_type_id: r.task_type_id,
    date: r.date,
    status: r.status,
    subjects: (r.task_subject ?? []).map((s: any) => ({
      user_plant_id: s.user_plant_id,
      area_id: s.area_id,
    })),
    hasReminder: (r.task_reminder ?? []).length > 0,
    supplyIds: (r.task_supply ?? []).map((ts: any) => ts.supply_id),
  }));

  return {
    profile: profileRes.data,
    areas: areasRes.data ?? [],
    plants: (plantsRes.data ?? []).map((p: any) => ({
      id: p.id,
      area_id: p.area_id,
      plant_id: p.plant_id,
      custom_name: p.custom_name,
      personal_alias: p.personal_alias,
      is_custom: p.is_custom,
      category: p.plant?.category ?? null,
    })),
    tasks,
    supplies: suppliesRes.data ?? [],
    suggestionLog: logRes.data ?? [],
    activeSuggestions: suggestionsRes.data ?? [],
  };
}
