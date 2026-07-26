// Push title assembly. The generated catalog (_shared/push_i18n.ts) mirrors the
// app's message templates, so four of its titles carry a `{task}` marker
// ('{task} je na vrsti', '{task} v okolici', …). In the app the client fills
// those markers; a push has no client, so the engine must fill them here or the
// notification shade shows a literal brace.

import { pushTitle } from '../_shared/push_i18n.ts';
import type { TaskTypeMeta } from './types.ts';

/** The task type's name in the profile's language, falling back to English and
 * finally to the raw id — a push with the id in it is ugly but still tells the
 * reader which task it is. */
export function taskLabel(type: TaskTypeMeta | undefined, lang: string | null): string {
  if (!type) return '';
  const labels = type.labels;
  if (labels == null) return type.id;
  return labels[lang ?? ''] ?? labels.en ?? type.id;
}

/** The localized push title with its markers filled. An unknown marker collapses
 * to empty (same rule as the client's fillTemplate) — never a stray brace. */
export function pushTitleFor(
  messageKey: string,
  lang: string | null,
  type: TaskTypeMeta | undefined,
): string {
  const label = taskLabel(type, lang);
  return pushTitle(messageKey, lang)
    .replace(/\{(\w+)\}/g, (_, marker) => (marker === 'task' ? label : ''))
    .trim();
}
