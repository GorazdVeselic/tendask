import { assertEquals, assertStringIncludes } from 'jsr:@std/assert@1';
import { kPushMessageKeys, pushBody, pushTitle } from '../_shared/push_i18n.ts';
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
  assertEquals(pushTitleFor('suggestions.nope', 'sl', kSow), 'Tvoj vrt te čaka');
});

Deno.test('the only marker shipped to push is {task}, the one the engine can fill', () => {
  // The whole catalog, not a sample. pushTitleFor() collapses *any* unknown
  // marker to empty, so checking the filled string proves nothing: "{subject}
  // is due" would quietly ship as " is due". The invariant lives one step
  // earlier — a push title may only ask for what the engine has (M11.12, P10.2).
  for (const lang of ['en', 'sl', 'de']) {
    for (const key of kPushMessageKeys) {
      const raw = pushTitle(key, lang);
      const markers = [...raw.matchAll(/\{(\w+)\}/g)].map((m) => m[1]);
      assertEquals(markers.filter((m) => m !== 'task'), [], `${lang} ${key}: ${raw}`);
      const filled = pushTitleFor(key, lang, kSow);
      assertEquals(/[{}]/.test(filled), false, `${lang} ${key}: ${filled}`);
      assertEquals(filled.length > 0, true, `${lang} ${key} fills to nothing`);
    }
    // The body never comes from a template, so it never has a marker to fill.
    assertEquals(/[{}]/.test(pushBody(lang)), false, `${lang} body`);
  }
});

Deno.test('UI-only strings are not in the push catalog', () => {
  // The generator used to harvest every suggestions.*.title, which swept up the
  // done sheet and the remove dialog — neither can ever be a message_key (P10.2).
  assertEquals(kPushMessageKeys.includes('suggestions.done_sheet'), false);
  assertEquals(kPushMessageKeys.includes('suggestions.remove'), false);
  assertStringIncludes(kPushMessageKeys.join(' '), 'suggestions.lawn.mow_due');
});

Deno.test('a missing label degrades to the id rather than an empty title', () => {
  const bare: TaskTypeMeta = { ...kSow, labels: null };
  assertEquals(pushTitleFor('suggestions.community.most_started', 'sl', bare), 'sow v okolici');
});

Deno.test('an unsupported language falls back to English', () => {
  assertEquals(taskLabel(kSow, 'fr'), 'Sowing');
  assertEquals(taskLabel(kSow, null), 'Sowing');
});
