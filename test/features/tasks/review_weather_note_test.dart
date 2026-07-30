import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/location/h3_cells.dart';
import 'package:tendask/core/location/location_repository.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/supplies/application/supplies_providers.dart';
import 'package:tendask/features/tasks/presentation/entry/steps/review_step.dart';
import 'package:tendask/i18n/translations.g.dart';

const _gardenPoint = (latitude: 46.22, longitude: 15.39);
final _date = DateTime(2026, 7, 30, 8);

TaskType _taskType() => TaskType(
  id: 'water',
  labels: jsonEncode({'sl': 'Zalivanje', 'en': 'Watering', 'de': 'Gießen'}),
  icon: '💧',
  category: 'water',
  requiresSubject: true,
  weatherSensitive: true,
  consumesSupplies: false,
  defaultCadence: null,
);

/// Plain text of the rich no-location sentence — the review step renders it
/// without a link, so it must be compared as text, not found by `find.text`.
String get _noLocationNote =>
    t.weather.detail_no_location(link: (text) => TextSpan(text: text))
        .toPlainText();

Future<void> _pump(WidgetTester tester, {required GardenCoords? location}) async {
  // The note is the last child of the step's ListView; a short viewport never
  // builds it, so the assertion would pass or fail for the wrong reason.
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final controller = TextEditingController();
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          gardenLocationProvider.overrideWith((ref) => Stream.value(location)),
          taskTypesMapProvider.overrideWith(
            (ref) => Stream.value({'water': _taskType()}),
          ),
          areasMapProvider.overrideWith((ref) => Stream.value(<String, Area>{})),
          userPlantsMapProvider.overrideWith(
            (ref) => Stream.value(<String, UserPlant>{}),
          ),
          plantsMapProvider.overrideWith((ref) => Stream.value(<String, Plant>{})),
          suppliesListProvider.overrideWith((ref) => Stream.value(<Supply>[])),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: ReviewStepBody(
                taskTypeId: 'water',
                subjects: const [],
                date: _date,
                status: TaskStatus.waiting,
                recurrence: null,
                reminders: const [],
                supplies: const [],
                noteController: controller,
                consumesSupplies: false,
                onFix: (_) {},
                showYield: false,
                yieldAmount: null,
              yieldUnit: null,
              onEditYield: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('with a location the review step promises a snapshot', (
    tester,
  ) async {
    await _pump(tester, location: _gardenPoint);

    expect(find.textContaining(t.entry.weather_note), findsOne);
    expect(find.textContaining(_noLocationNote), findsNothing);
  });

  testWidgets('without a location it promises nothing it cannot deliver', (
    tester,
  ) async {
    await _pump(tester, location: null);

    expect(find.textContaining(t.entry.weather_note), findsNothing);
    expect(find.textContaining(_noLocationNote), findsOne);
  });
}
