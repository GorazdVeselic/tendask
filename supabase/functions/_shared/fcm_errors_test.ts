import { assertEquals } from 'jsr:@std/assert@1';
import { fcmErrorCode, isDeadTokenResponse } from './fcm_errors.ts';

function errorBody(status: string, errorCode?: string): string {
  return JSON.stringify({
    error: {
      code: 400,
      message: 'x',
      status,
      details: errorCode
        ? [{ '@type': 'type.googleapis.com/google.firebase.fcm.v1.FcmError', errorCode }]
        : [],
    },
  });
}

Deno.test('a device that is gone clears the token', () => {
  assertEquals(isDeadTokenResponse(404, errorBody('NOT_FOUND', 'UNREGISTERED')), true);
  assertEquals(isDeadTokenResponse(404, ''), true); // NOT_FOUND without details
  assertEquals(isDeadTokenResponse(403, errorBody('PERMISSION_DENIED', 'SENDER_ID_MISMATCH')), true);
  // The status alone does not decide — UNREGISTERED can arrive as a 400.
  assertEquals(isDeadTokenResponse(400, errorBody('INVALID_ARGUMENT', 'UNREGISTERED')), true);
});

Deno.test('a rejected message never costs a token', () => {
  // One over-long title or an unknown android channel_id would otherwise wipe
  // the token of every user in the batch, on every run.
  assertEquals(isDeadTokenResponse(400, errorBody('INVALID_ARGUMENT')), false);
  assertEquals(isDeadTokenResponse(400, ''), false);
  assertEquals(isDeadTokenResponse(400, errorBody('INVALID_ARGUMENT', 'THIRD_PARTY_AUTH_ERROR')), false);
});

Deno.test('a transient failure never costs a token', () => {
  assertEquals(isDeadTokenResponse(500, ''), false);
  assertEquals(isDeadTokenResponse(503, errorBody('UNAVAILABLE', 'UNAVAILABLE')), false);
  assertEquals(isDeadTokenResponse(429, errorBody('RESOURCE_EXHAUSTED', 'QUOTA_EXCEEDED')), false);
});

Deno.test('a non-JSON body is read as "unknown", not as a dead token', () => {
  const html = '<html><body>502 Bad Gateway</body></html>';
  assertEquals(fcmErrorCode(html), null);
  assertEquals(isDeadTokenResponse(502, html), false);
  assertEquals(fcmErrorCode(errorBody('NOT_FOUND', 'UNREGISTERED')), 'UNREGISTERED');
});
