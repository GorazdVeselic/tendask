import 'package:flutter/material.dart';

/// Placeholder for the moon calendar (FR-19): the route exists so the redirect
/// guard is in place, but the screen is reachable only with
/// `kMoonCalendarEnabled` flipped on manually. T3 replaces it with the real
/// month/week calendar.
class MoonCalendarScreen extends StatelessWidget {
  const MoonCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
}
