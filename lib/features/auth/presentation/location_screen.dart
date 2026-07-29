import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/location/geocoding_client.dart';
import '../../../core/location/location_repository.dart';
import '../../../core/location/location_service.dart';
import '../../../core/location/place_label_repository.dart';
import '../../../core/widgets/confirm_dialog.dart';
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
  // Scroll anchors: the search card goes to the top of the (keyboard-shrunk)
  // viewport once results arrive; the banner is the only save confirmation and
  // the error sits far from the GPS card, so both must be brought into view.
  final _entryCardKey = GlobalKey();
  final _bannerKey = GlobalKey();
  final _errorKey = GlobalKey();
  bool _loading = false;
  bool _isSet = false;
  String? _error;

  /// The place the user just picked. Shown in the banner ahead of the resolved
  /// label, which arrives late and never at all when offline.
  String? _pickedName;
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
      setState(() {
        _isSet = true;
        // A GPS fix carries no place name, and the previously typed one belongs
        // to the cell we just replaced.
        _pickedName = null;
      });
      _ensureVisible(_bannerKey);
    } else {
      setState(() => _error = locationErrorLabel(result, t));
      _ensureVisible(_errorKey);
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
      if (results.isNotEmpty) _ensureVisible(_entryCardKey);
    } on Object {
      if (!mounted) return;
      setState(() => _error = t.location.err_search);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Aligns [key]'s widget to the top of the visible area — which the keyboard
  /// may have shrunk — once the frame that renders it is on screen.
  void _ensureVisible(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = key.currentContext;
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
    await _save(place.latitude, place.longitude);
    if (!mounted) return;
    setState(() {
      _isSet = true;
      _pickedName = place.name;
      _results = const [];
      _error = null;
    });
    FocusScope.of(context).unfocus();
    _ensureVisible(_bannerKey);
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
      _pickedName = null;
      _results = const [];
      _error = null;
    });
    _ensureVisible(_bannerKey);
  }

  /// The GPS option: the "or" divider and the card itself, kept together
  /// wherever they land — pinned to the bottom in onboarding, inline in the
  /// list from settings and while the keyboard is up.
  List<Widget> _gpsOption({bool emphasised = false}) => [
    const SizedBox(height: 14),
    const OrDivider(),
    const SizedBox(height: 14),
    GpsCard(loading: _loading, onTap: _useGps, emphasised: emphasised),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // From settings (push): a back arrow and no continue button — picks save on
    // tap. From the onboarding/login flow (go): no back, a "Continue" button
    // advances to home.
    final fromSettings = context.canPop();
    // The place shown in the status banner: the freshly picked one, else the
    // resolved label for the stored cell (same source as the weather card),
    // which is null until it resolves and stays null offline.
    final placeName = _isSet
        ? _pickedName ??
              ref
                  .watch(
                    placeLabelProvider(
                      LocaleSettings.currentLocale.languageCode,
                    ),
                  )
                  .value
        : null;
    final error = _error;
    // Onboarding pins the GPS option and the exit button to the bottom, within
    // thumb reach; from settings the option stays inline and there is no exit
    // button at all (a pick saves on the spot). While the keyboard is up the
    // pinned block would squeeze the list that holds the search matches, so it
    // steps aside until typing is done.
    final showBottomBlock =
        !fromSettings && MediaQuery.viewInsetsOf(context).bottom == 0;

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
                      key: _bannerKey,
                      isSet: _isSet,
                      placeName: placeName,
                      onClear: _isSet ? _clear : null,
                    ),
                    const SizedBox(height: 4),
                    // Wireframe sizing (74 dp tile, 38 dp glyph). The decorative
                    // header is what pushed the privacy note — the reassurance
                    // the user needs *before* handing over a location — below
                    // the fold on a normal phone.
                    Center(
                      child: Container(
                        width: 74,
                        height: 74,
                        margin: const EdgeInsets.only(top: 4, bottom: 12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 38,
                          color: cs.primary,
                        ),
                      ),
                    ),
                    Text(
                      t.location.title,
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t.location.why,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
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
                    if (_loading) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        error,
                        key: _errorKey,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.error,
                        ),
                      ),
                    ],
                    if (!showBottomBlock) ..._gpsOption(),
                    const SizedBox(height: 16),
                    LocationPrivacyNote(text: t.location.privacy),
                  ],
                ),
              ),
              if (showBottomBlock) ...[
                ..._gpsOption(emphasised: !_isSet),
                const SizedBox(height: 10),
                _ExitButton(
                  isSet: _isSet,
                  onPressed: () => context.go('/home'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The way out of the onboarding step. It carries the emphasis only once a
/// location is set; until then the emphasis belongs to the GPS card above it,
/// so nothing prominent leads past the step (FR-24). Both variants are the same
/// size, so the button does not move under the thumb when the state flips.
class _ExitButton extends StatelessWidget {
  const _ExitButton({required this.isSet, required this.onPressed});

  final bool isSet;
  final VoidCallback onPressed;

  // A minimum, not a fixed height: a label that wraps to two lines has to grow
  // the button instead of being silently clipped (docs/ui-katalog.md).
  static const _size = Size(double.infinity, 52);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final cs = Theme.of(context).colorScheme;
    if (isSet) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(minimumSize: _size),
        child: Text(t.location.kContinue),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: _size,
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        side: BorderSide(color: cs.outlineVariant, width: 1.5),
      ),
      child: Text(t.location.skip),
    );
  }
}
