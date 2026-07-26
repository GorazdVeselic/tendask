import { assertEquals } from 'jsr:@std/assert@1';
import { pushTitleFor, taskLabel } from './push_text.ts';
import type { TaskTypeMeta } from './types.ts';

const kSow: TaskTypeMeta = {
  id: 'sow',
  default_cadence: null,
  weather_sensitive: true,
  seasonal: true,
  labels: { en: 'Sowing', sl: 'Setev', de: 'Aussaat' },
};

Deno.test('a {task} title is filled, never sent with a literal brace', () => {
  assertEquals(
    pushTitleFor('suggestions.community.most_started', 'sl', kSow),
    'Setev v okolici',
  );
  assertEquals(
    pushTitleFor('suggestions.cadence.overdue', 'de', kSow),
    'Aussaat ist fällig',
  );
});

Deno.test('a title without markers passes through untouched', () => {
  assertEquals(pushTitleFor('suggestions.lawn.mow_due', 'sl', undefined), 'Čas za košnjo');
});

Deno.test('an unknown message key falls back to the generic title', () => {
  assertEquals(pushTitleFor('suggestions.nope', 'sl', kSow), 'Vaš vrt čaka na vas');
});

Deno.test('a missing label degrades to the id rather than an empty title', () => {
  const bare: TaskTypeMeta = { ...kSow, labels: null };
  assertEquals(pushTitleFor('suggestions.community.most_started', 'sl', bare), 'sow v okolici');
});

Deno.test('an unsupported language falls back to English', () => {
  assertEquals(taskLabel(kSow, 'fr'), 'Sowing');
  assertEquals(taskLabel(kSow, null), 'Sowing');
});
