// Classifying an FCM HTTP v1 error response. Split from fcm.ts so it is unit
// testable without the service-account secret or the npm OAuth dependency.

/** `error.details[].errorCode` from an FCM v1 error body, when present. */
export function fcmErrorCode(body: string): string | null {
  try {
    const details = (JSON.parse(body) as { error?: { details?: unknown } })?.error?.details;
    if (!Array.isArray(details)) return null;
    for (const d of details) {
      const code = (d as { errorCode?: unknown })?.errorCode;
      if (typeof code === 'string') return code;
    }
    return null;
  } catch {
    return null; // not JSON (HTML error page, proxy) — never a reason to drop a token
  }
}

/** True only when this device will never receive again, so the stored token must
 * be cleared.
 *
 * A bare 400 is NOT that: INVALID_ARGUMENT describes the MESSAGE (title too
 * long, unknown android channel_id), so treating it as a dead token lets one bad
 * message wipe the tokens of every user in the batch, on every run. The cost of
 * the opposite mistake is one failed send per day for one user. */
export function isDeadTokenResponse(status: number, body: string): boolean {
  const code = fcmErrorCode(body);
  if (code === 'UNREGISTERED') return true; // app uninstalled / token rotated away
  if (code === 'SENDER_ID_MISMATCH') return true; // token belongs to another sender
  return status === 404 && code === null; // NOT_FOUND without details
}
