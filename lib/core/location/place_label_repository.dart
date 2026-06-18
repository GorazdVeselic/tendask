import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'h3_cells.dart';
import 'location_repository.dart';
import 'reverse_geocoding_client.dart';

part 'place_label_repository.g.dart';

const _kPlaceLabel = 'place_label';

/// A cached place label tied to the cell + language it was resolved for, so we
/// re-geocode only when the garden moves or the app language changes.
typedef CachedPlaceLabel = ({String cell, String label, String lang});

/// Persists the last resolved place label (device-local, never synced) in the
/// local_flag store, so the weather card can show it offline and we avoid a
/// reverse-geocode call on every dashboard visit (FR-12).
class PlaceLabelRepository {
  PlaceLabelRepository(this._db);

  final AppDatabase _db;

  /// The last persisted label, or null when none/unparseable.
  Future<CachedPlaceLabel?> load() async {
    final row = await (_db.select(
      _db.localFlags,
    )..where((f) => f.key.equals(_kPlaceLabel))).getSingleOrNull();
    final raw = row?.value;
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final cell = j['cell'], label = j['label'], lang = j['lang'];
      if (cell is String && label is String && lang is String) {
        return (cell: cell, label: label, lang: lang);
      }
    } on FormatException catch (e) {
      debugPrint('Place label cache unparseable: $e');
    }
    return null;
  }

  Future<void> save(CachedPlaceLabel entry) => _db
      .into(_db.localFlags)
      .insertOnConflictUpdate(
        LocalFlagsCompanion.insert(
          key: _kPlaceLabel,
          value: jsonEncode({
            'cell': entry.cell,
            'label': entry.label,
            'lang': entry.lang,
          }),
        ),
      );
}

@riverpod
PlaceLabelRepository placeLabelRepository(Ref ref) =>
    PlaceLabelRepository(ref.watch(databaseProvider));

/// The place name for the current garden cell in [language] (FR-12), or null
/// when no location is set, none resolved yet, or we are offline with no usable
/// last-known label. Reactive to the garden cell (re-resolves when it changes).
///
/// Order: a cache hit for the same cell+language needs no network; otherwise we
/// reverse-geocode the cell centroid and cache it. On a network failure (or a
/// response with no usable name) we fall back to the last-known label only when
/// it is for the same cell — so a moved garden never shows a stale, wrong place.
@riverpod
Future<String?> placeLabel(Ref ref, String language) async {
  final cell = await ref.watch(gardenCellProvider.future);
  if (cell == null) return null; // no location set → weather is the generic default

  final repo = ref.watch(placeLabelRepositoryProvider);
  final cached = await repo.load();
  if (cached != null && cached.cell == cell && cached.lang == language) {
    return cached.label;
  }

  String? lastKnownForThisCell() =>
      cached != null && cached.cell == cell ? cached.label : null;

  final coords = cellCentroid(ref.watch(h3Provider), cell);
  if (coords == null) return lastKnownForThisCell();

  try {
    final name = await ref
        .watch(reverseGeocodingClientProvider)
        .reverseName(coords.latitude, coords.longitude, language: language);
    if (name == null || name.isEmpty) return lastKnownForThisCell();
    await repo.save((cell: cell, label: name, lang: language));
    return name;
  } on Exception {
    return lastKnownForThisCell();
  }
}
