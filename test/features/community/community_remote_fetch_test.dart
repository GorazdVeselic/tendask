import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;
import 'package:tendask/core/config.dart';
import 'package:tendask/features/community/data/community_remote_fetch.dart';

/// The ordering and the cap only exist as PostgREST query parameters, so the
/// only honest test is one that reads the request the client actually sends.
/// A loopback server stands in for PostgREST; nothing leaves the machine.
void main() {
  late HttpServer server;
  late SupabaseClient client;
  late List<Uri> requests;
  late List<Map<String, Object?>> reply;

  setUp(() async {
    requests = [];
    reply = [];
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    unawaited(
      server.forEach((request) async {
        requests.add(request.uri);
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(reply));
        await request.response.close();
      }),
    );
    client = SupabaseClient(
      'http://${server.address.address}:${server.port}',
      'anon-key',
    );
  });

  tearDown(() async {
    await client.dispose();
    await server.close(force: true);
  });

  Uri sent() => requests.single;

  test('an ordered table asks for its sort key and the cap', () async {
    final fetch = supabaseAggFetch(client);

    await fetch('activity_season', {
      'resolution': 'r7',
      'bucket_key': '871f1d4ffffffff',
    });

    expect(sent().path, '/rest/v1/activity_season');
    expect(sent().queryParameters['order'], 'year.desc.nullslast');
    expect(sent().queryParameters['limit'], '$kCommunityRowLimit');
    expect(sent().queryParameters['resolution'], 'eq.r7');
    expect(sent().queryParameters['bucket_key'], 'eq.871f1d4ffffffff');
  });

  test('the busiest cohorts survive the cut on the feed slice', () async {
    final fetch = supabaseAggFetch(client);

    await fetch('activity_recent', {'resolution': 'r6'});

    expect(sent().queryParameters['order'], 'distinct_users_7d.desc.nullslast');
  });

  test('a table without a sort key is still capped', () async {
    final fetch = supabaseAggFetch(client);

    await fetch('bucket_population', {'resolution': 'r5'});

    expect(sent().queryParameters['order'], isNull);
    expect(sent().queryParameters['limit'], '$kCommunityRowLimit');
  });

  test('a list filter becomes one "in" request, not one per value', () async {
    final fetch = supabaseAggFetch(client);

    await fetch('activity_season', {
      'resolution': 'r7',
      'task_type_id': ['prune', 'sow'],
    });

    expect(requests.length, 1);
    expect(sent().queryParameters['task_type_id'], 'in.("prune","sow")');
  });

  test('rows come back as decoded maps', () async {
    reply = [
      {'task_type_id': 'prune', 'iso_week': 12},
    ];
    final fetch = supabaseAggFetch(client);

    final rows = await fetch('activity_season', {'resolution': 'r7'});

    expect(rows, [
      {'task_type_id': 'prune', 'iso_week': 12},
    ]);
  });
}
