import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/location/geocoding_client.dart';
import '../../../core/location/location_repository.dart';
import '../../../core/location/location_service.dart';
import '../../../i18n/translations.g.dart';

/// Onboarding location step (wireframe 16). GPS via geolocator, or type a place
/// (Open-Meteo geocoding). Either way only the derived H3 cells are stored to
/// profile; the raw coordinates stay device-local (LocationRepository).
class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final _searchController = TextEditingController();
  bool _loading = false;
  String? _status;
  String? _error;
  List<GeoPlace> _results = const [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _save(double latitude, double longitude) async {
    final userId = ref.read(authServiceProvider).userId;
    await ref.read(locationRepositoryProvider).saveGardenLocation(
          userId: userId,
          latitude: latitude,
          longitude: longitude,
        );
  }

  Future<void> _useGps() async {
    final t = context.t;
    setState(() {
      _loading = true;
      _error = null;
      _status = null;
      _results = const [];
    });
    final result = await ref.read(locationServiceProvider).currentCoordinates();
    if (!mounted) return;
    switch (result) {
      case LocationCoords(:final latitude, :final longitude):
        await _save(latitude, longitude);
        if (!mounted) return;
        setState(() => _status = t.location.set_gps);
      case LocationDenied():
        setState(() => _error = t.location.err_denied);
      case LocationServiceDisabled():
        setState(() => _error = t.location.err_disabled);
      case LocationUnavailable():
        setState(() => _error = t.location.err_unavailable);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _search() async {
    final t = context.t;
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _status = null;
    });
    try {
      final lang = LocaleSettings.currentLocale.languageCode;
      final results = await ref
          .read(geocodingClientProvider)
          .search(query, language: lang);
      if (!mounted) return;
      setState(() {
        _results = results;
        if (results.isEmpty) _error = t.location.no_results;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _error = t.location.err_search);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectPlace(GeoPlace place) async {
    final t = context.t;
    await _save(place.latitude, place.longitude);
    if (!mounted) return;
    setState(() {
      _status = t.location.set_place(name: place.name);
      _results = const [];
      _error = null;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 10, 26, 24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Icon(Icons.location_on_outlined,
                            size: 46, color: cs.primary),
                      ),
                    ),
                    Text(
                      t.location.title,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t.location.why,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _loading ? null : _useGps,
                        icon: const Icon(Icons.my_location, size: 20),
                        label: Text(t.location.use_gps),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            t.location.or_enter,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: t.location.place_hint,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _loading ? null : _search,
                        ),
                      ),
                      onSubmitted: (_) => _loading ? null : _search(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.location.place_note,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    if (_loading) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    for (final place in _results)
                      ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(place.name),
                        subtitle: Text([place.admin1, place.country]
                            .whereType<String>()
                            .join(', ')),
                        onTap: () => _selectPlace(place),
                      ),
                    if (_status != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: cs.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_status!,
                                style: theme.textTheme.bodyMedium),
                          ),
                        ],
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: cs.error),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _PrivacyNote(text: t.location.privacy),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  // From the login flow (go) there's nothing to pop → home;
                  // from settings (push) pop back to settings.
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/home'),
                  child: Text(t.location.kContinue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.infoSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.info,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
