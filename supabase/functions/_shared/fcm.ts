// FCM HTTP v1 push sender (docs/m11/04-supabase-shema.md §4.8).
// Legacy server key ukinjen jun. 2024 → service account OAuth JWT.
// Env: FCM_SERVICE_ACCOUNT_JSON (supabase secrets set).
import { importPKCS8, SignJWT } from 'jose';
import { isDeadTokenResponse } from './fcm_errors.ts';

// Without a deadline a hung Google endpoint holds the whole batch: every user
// after this one waits, and the edge function's own budget runs out.
const kFcmTimeoutMs = 10_000;

let cachedToken: { token: string; exp: number } | null = null;
let cachedProjectId: string | null = null;

// Fail closed with a named error if the secret is missing — a bare `!` would
// throw an opaque "Cannot read of null" deep inside JSON.parse.
function serviceAccount(): Record<string, string> {
  const raw = Deno.env.get('FCM_SERVICE_ACCOUNT_JSON');
  if (!raw) throw new Error('FCM_SERVICE_ACCOUNT_JSON secret is not set');
  return JSON.parse(raw);
}

async function oauthToken(): Promise<string> {
  if (cachedToken && cachedToken.exp > Date.now() / 1000 + 60) return cachedToken.token;
  const sa = serviceAccount();
  if (!cachedProjectId) cachedProjectId = sa.project_id as string;
  const key = await importPKCS8(sa.private_key as string, 'RS256');
  const jwt = await new SignJWT({
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  })
    .setProtectedHeader({ alg: 'RS256' })
    .setIssuer(sa.client_email as string)
    .setAudience(sa.token_uri as string)
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(key);
  const res = await fetch(sa.token_uri as string, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
    signal: AbortSignal.timeout(kFcmTimeoutMs),
  });
  if (!res.ok) throw new Error(`FCM OAuth ${res.status}: ${await res.text()}`);
  const { access_token, expires_in } = (await res.json()) as {
    access_token: string;
    expires_in: number;
  };
  cachedToken = { token: access_token, exp: Date.now() / 1000 + expires_in };
  return access_token;
}

/** Project ID from the service account JSON (cached after first call). */
export function fcmProjectId(): string {
  if (!cachedProjectId) {
    cachedProjectId = serviceAccount().project_id as string;
  }
  return cachedProjectId!;
}

/** Sends one suggestion push.
 * Returns false ONLY when the device is gone (the caller nulls the token); a
 * rejected message throws instead, so a bad payload never costs a token. */
export async function sendSuggestionPush(opts: {
  fcmToken: string;
  projectId: string;
  title: string;
  body: string;
  suggestionId: string;
}): Promise<boolean> {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${opts.projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${await oauthToken()}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token: opts.fcmToken,
          notification: { title: opts.title, body: opts.body },
          data: { type: 'suggestion', suggestion_id: opts.suggestionId },
          android: { notification: { channel_id: 'suggestions' } },
        },
      }),
      signal: AbortSignal.timeout(kFcmTimeoutMs),
    },
  );
  if (res.ok) {
    await res.body?.cancel(); // an unread body keeps the connection open
    return true;
  }
  const body = await res.text();
  if (isDeadTokenResponse(res.status, body)) return false;
  throw new Error(`FCM ${res.status}: ${body}`);
}
