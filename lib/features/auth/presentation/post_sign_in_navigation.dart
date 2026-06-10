import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_repository.dart';

/// Routes after sign-in or guest entry: straight to home when this device
/// already has a garden location, otherwise to the location step. Raw coords
/// stay device-local and are never restored from the cloud, so this is the
/// reliable "already set" signal (see BUG-002).
Future<void> goToLocationOrHome(BuildContext context, WidgetRef ref) async {
  final coords = await ref.read(locationRepositoryProvider).gardenCoordinates();
  if (!context.mounted) return;
  context.go(coords != null ? '/home' : '/location');
}
