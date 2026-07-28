// The garden the season simulation runs on, and the seeding of a SimDb with it.
// Split from season_sim_test.ts so the test file stays about the measurement.
//
// The garden is deliberately broad rather than typical: it activates every rule
// archetype at once (month_window, frost_offset, growth_stage chain,
// cadence_only with and without a season gate, plus the history rules R2/R3 and
// the community rule R6). A narrower garden would under-report — a rule that
// never gets a subject cannot be caught firing too often.
// deno-lint-ignore-file no-explicit-any
import { SimDb } from './sim_db.ts';
import { kPlantTaskRuleRows, kTaskTypeRows } from './testdata/catalog_fixture.ts';

export const kUserId = 'u-sim';
export const kTimeZone = 'Europe/Ljubljana';
export const kCellR7 = '871e13904ffffff';

/** Last frost ≈ 20 Apr, first frost ≈ 20 Oct — continental Slovenia, matching
 * the weather series in synthetic_weather.ts. */
export const kClimateProfile = {
  frost_last_spring_doy: 110,
  frost_first_autumn_doy: 293,
  growing_season_days: 183,
  hemisphere: 'north',
};

export const kAreas = [
  { id: 'a-lawn', name: 'Trata', type: 'lawn', protected: false, deleted: false },
  { id: 'a-bed', name: 'Greda', type: 'bed', protected: false, deleted: false },
  { id: 'a-glass', name: 'Rastlinjak', type: 'greenhouse', protected: true, deleted: false },
];

/** basil sits in the greenhouse on purpose: guard 5g skips the weather guard for
 * a protected subject, which is a different emission path from the open garden. */
export const kPlants = [
  { id: 'p-apple', area_id: 'a-bed', plant_id: 'apple', category: 'fruit_tree' },
  { id: 'p-tomato', area_id: 'a-bed', plant_id: 'tomato', category: 'vegetable' },
  { id: 'p-raspberry', area_id: 'a-bed', plant_id: 'raspberry', category: 'berries' },
  { id: 'p-basil', area_id: 'a-glass', plant_id: 'basil', category: 'herbs' },
];

/** Done tasks from the season before the simulated year. They give R3 a learned
 * cadence, R2 an anniversary and R7 a chain step to follow — without history the
 * history rules are silent and the simulation would measure only R5/R6. */
const kHistory: { day: string; type: string; subject: string }[] = [
  // A mowing cadence the user actually kept: median gap 7 days.
  { day: '2025-05-04', type: 'mow', subject: 'ar:a-lawn' },
  { day: '2025-05-11', type: 'mow', subject: 'ar:a-lawn' },
  { day: '2025-05-18', type: 'mow', subject: 'ar:a-lawn' },
  { day: '2025-05-25', type: 'mow', subject: 'ar:a-lawn' },
  { day: '2025-06-01', type: 'mow', subject: 'ar:a-lawn' },
  // Seasonal one-offs a year ago → R2 anniversary candidates.
  { day: '2025-03-08', type: 'prune', subject: 'up:p-apple' },
  { day: '2025-04-12', type: 'fertilize', subject: 'up:p-apple' },
  { day: '2025-09-14', type: 'scarify', subject: 'ar:a-lawn' },
  // Watering the greenhouse basil, twice a week.
  { day: '2025-06-03', type: 'water', subject: 'up:p-basil' },
  { day: '2025-06-06', type: 'water', subject: 'up:p-basil' },
  { day: '2025-06-10', type: 'water', subject: 'up:p-basil' },
];

/** Community curves from a completed season, so R6 has something to read. Two
 * cohorts clear k_reliab (30); the rest stay below and must not produce cards. */
function activitySeasonRows(): any[] {
  const rows: any[] = [];
  const curve = (
    taskTypeId: string,
    plantId: string,
    weeks: [number, number][],
  ) => {
    for (const [week, count] of weeks) {
      rows.push({
        resolution: 'r7',
        bucket_key: kCellR7,
        task_type_id: taskTypeId,
        plant_id: plantId,
        year: 2025,
        iso_week: week,
        first_user_count: count,
      });
    }
  };
  // Sowing tomatoes: the neighbourhood starts weeks 10–16, 34 gardeners.
  curve('sow', 'tomato', [[10, 3], [11, 5], [12, 8], [13, 7], [14, 6], [15, 3], [16, 2]]);
  // Pruning apples: late winter, 31 gardeners.
  curve('prune', 'apple', [[6, 4], [7, 6], [8, 9], [9, 7], [10, 5]]);
  // Below k_reliab — present so the simulation proves it stays silent.
  curve('mulch', 'raspberry', [[14, 3], [15, 4]]);
  return rows;
}

export interface DoneTask {
  day: string;
  type: string;
  subject: string;
}

/** A fresh store holding the whole garden, ready for day 1. */
export function seedSimDb(extraHistory: DoneTask[] = []): SimDb {
  const db = new SimDb();
  const tasks = [...kHistory, ...extraHistory].map((h, i) => ({
    id: `t-${i}-${h.type}`,
    user_id: kUserId,
    task_type_id: h.type,
    date: h.day + 'T10:00:00Z',
    status: 'done',
    deleted: false,
    task_subject: [subjectColumns(h.subject)],
    task_reminder: [],
    task_supply: [],
  }));

  db.rows = {
    app_config: [
      { key: 'engine_enabled', value: true },
      { key: 'k_privacy', value: 5 },
      { key: 'k_reliab', value: 30 },
    ],
    task_type: kTaskTypeRows.map((t) => ({ ...t })),
    plant_task_rule: kPlantTaskRuleRows.map((r) => ({ ...r })),
    profile: [{
      user_id: kUserId,
      h3_r7: kCellR7,
      h3_r6: '861e1391fffffff',
      h3_r5: '851e1393fffffff',
      timezone: kTimeZone,
      lang: 'sl',
      climate_bucket: 'e1_t6',
      climate_profile: kClimateProfile,
      fcm_token: 'tok-sim',
      notification_settings: { weather_hints: true, community_hints: true },
    }],
    area: kAreas.map((a) => ({ ...a, user_id: kUserId })),
    user_plant: kPlants.map((p) => ({
      id: p.id,
      user_id: kUserId,
      area_id: p.area_id,
      plant_id: p.plant_id,
      custom_name: null,
      personal_alias: null,
      is_custom: false,
      deleted: false,
      plant: { category: p.category },
    })),
    task: tasks,
    supply: [],
    suggestion: [],
    suggestion_log: [],
    engine_run: [],
    weather_cache: [],
    activity_season: activitySeasonRows(),
  };
  return db;
}

export function subjectColumns(subjectKey: string): {
  user_plant_id: string | null;
  area_id: string | null;
} {
  if (subjectKey.startsWith('up:')) {
    return { user_plant_id: subjectKey.slice(3), area_id: null };
  }
  return { user_plant_id: null, area_id: subjectKey.slice(3) };
}
