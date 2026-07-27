// smart-engine Edge Function entry point. Everything testable lives in
// handler.ts; this file only binds the pieces that need npm — the supabase
// client, the h3 centroid lookup and the FCM sender — so a test can drive the
// whole request with fakes instead of a live project.
// Spec: docs/m11/04-supabase-shema.md §4.7.

import { createClient } from '@supabase/supabase-js';
import { cellToLatLng } from 'h3-js';
import { fcmProjectId, sendSuggestionPush } from '../_shared/fcm.ts';
import { handleRequest } from './handler.ts';

Deno.serve((req) =>
  handleRequest(req, {
    env: {
      url: Deno.env.get('SUPABASE_URL') ?? '',
      serviceKey: Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    },
    makeDb: (url, key) => createClient(url, key),
    now: () => new Date(),
    latLngOf: cellToLatLng,
    sendPush: sendSuggestionPush,
    projectId: fcmProjectId,
  })
);
