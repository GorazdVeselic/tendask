import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/location/geocoding_client.dart';
import '../../../core/location/location_repository.dart';
import '../../../core/location/location_service.dart';
import '../../../core/location/place_label_repository.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/top_toast.dart';
import '../../../i18n/translations.g.dart';
import 'location_labels.dart';
import 'widgets/enter_place_card.dart';
import 'widgets/gps_card.dart';
import 'widgets/location_privacy_note.dart';
import 'widgets/location_status_banner.dart';

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
  // Lets us scroll the search card up to the top of the (keyboard-shrunk)
  // viewport once results arrive, so the matches aren't hidden by the keyboard.
  final _entryCardKey = GlobalKey();
  bool _loading = false;
  bool _isSet = false;
  String? _error;
  List<GeoPlace> _results = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSetState);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSetState() async {
    final cell = await ref.read(locationRepositoryProvider).gardenCell();
    if (!mounted) return;
    setState(() => _isSet = cell != null);
  }

  void _toast(String message) => showTopToast(context, message);

  Future<void> _save(double latitude, double longitude) async {
    final userId = ref.read(authServiceProvider).userId;
    await ref
        .read(locationRepositoryProvider)
        .saveGardenLocation(
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
      _results = const [];
    });
    final result = await ref.read(locationServiceProvider).currentCoordinates();
    if (!mounted) return;
    if (result case LocationCoords(:final latitude, :final longitude)) {
      await _save(latitude, longitude);
      if (!mounted) return;
      setState(() => _isSet = true);
      _toast(t.location.set_gps);
    } else {
      setState(() => _error = locationErrorLabel(result, t));
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
      if (results.isNotEmpty) _scrollEntryCardToTop();
    } on Object {
      if (!mounted) return;
      setState(() => _error = t.location.err_search);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// After matches render, align the search card to the top of the visible area
  /// (the viewport is already shrunk above the keyboard) so the list shows.
  void _scrollEntryCardToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _entryCardKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        alignment: 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _selectPlace(GeoPlace place) async {
    final t = context.t;
    await _save(place.latitude, place.longitude);
    if (!mounted) return;
    setState(() {
      _isSet = true;
      _results = const [];
      _error = null;
    });
    _toast(t.location.set_place(name: place.name));
    FocusScope.of(context).unfocus();
  }

  Future<void> _clear() async {
    final t = context.t;
    final confirmed = await showConfirmDialog(
      context,
      title: t.location.clear_confirm_title,
      body: t.location.clear_confirm_body,
      confirmLabel: t.location.clear_confirm_yes,
      cancelLabel: t.location.clear_confirm_cancel,
    );
    if (!confirmed || !mounted) return;
    final userId = ref.read(authServiceProvider).userId;
    await ref.read(locationRepositoryProvider).clearGardenLocation(userId);
    if (!mounted) return;
    setState(() {
      _isSet = false;
      _results = const [];
      _error = null;
    });
    _toast(t.location.cleared);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // From settings (push): a back arrow and no continue button — picks save on
    // tap. From the onboarding/login flow (go): no back, a "Continue" button
    // advances to home.
    final fromSettings = context.canPop();
    // The resolved place name for the current cell (same source as the weather
    // card), shown in the status banner when set; null until resolved/offline.
    final placeName = _isSet
        ? ref
              .watch(
                placeLabelProvider(LocaleSettings.currentLocale.languageCode),
              )
              .value
        : null;
    final error = _error;

    return Scaffold(
      appBar: fromSettings
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: context.pop,
              ),
              title: Text(t.location.screen_title),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        top: !fromSettings,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 10, 26, 24),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    LocationStatusBanner(
                      isSet: _isSet,
                      placeName: placeName,
                      onClear: _isSet ? _clear : null,
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 46,
                          color: cs.primary,
                        ),
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
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Manual entry on top — typing a place name is the most
                    // universally understood action; GPS is the alternative.
                    EnterPlaceCard(
                      key: _entryCardKey,
                      controller: _searchController,
                      loading: _loading,
                      onSearch: _search,
                      results: _results,
                      onSelect: _selectPlace,
                    ),
                    const SizedBox(height: 14),
                    const OrDivider(),
                    const SizedBox(height: 14),
                    GpsCard(loading: _loading, onTap: _useGps),
                    if (_loading) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    LocationPrivacyNote(text: t.location.privacy),
                  ],
                ),
              ),
              if (!fromSettings) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => context.go('/home'),
                    child: Text(t.location.kContinue),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
