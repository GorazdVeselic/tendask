import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/location/geocoding_client.dart';
import '../../../core/location/location_repository.dart';
import '../../../core/location/location_service.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/top_toast.dart';
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
    switch (result) {
      case LocationCoords(:final latitude, :final longitude):
        await _save(latitude, longitude);
        if (!mounted) return;
        setState(() => _isSet = true);
        _toast(t.location.set_gps);
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
                    _StatusBanner(
                      isSet: _isSet,
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
                    _EnterPlaceCard(
                      controller: _searchController,
                      loading: _loading,
                      onSearch: _search,
                      results: _results,
                      onSelect: _selectPlace,
                    ),
                    const SizedBox(height: 14),
                    const _OrDivider(),
                    const SizedBox(height: 14),
                    _GpsCard(loading: _loading, onTap: _useGps),
                    if (_loading) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator()),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _PrivacyNote(text: t.location.privacy),
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

/// Shows whether a garden location is already set, with an inline remove action
/// when it is. Calm by design: set = green, unset = amber (attention, not error).
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.isSet, this.onClear});

  final bool isSet;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final bg = isSet ? AppColors.soft : AppColors.warnSoft;
    final fg = isSet ? AppColors.green900 : AppColors.warn;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isSet ? Icons.check_circle : Icons.error_outline,
            size: 18,
            color: fg,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isSet ? t.location.status_set : t.location.status_unset,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(t.location.clear),
            ),
        ],
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

/// Primary option: type a place name (Open-Meteo geocoding). Geocoded matches
/// render inline below the field; tapping one saves it.
class _EnterPlaceCard extends StatelessWidget {
  const _EnterPlaceCard({
    required this.controller,
    required this.loading,
    required this.onSearch,
    required this.results,
    required this.onSelect,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSearch;
  final List<GeoPlace> results;
  final ValueChanged<GeoPlace> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.primary, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(t.location.enter_place),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: t.location.place_hint,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: loading ? null : onSearch,
              ),
            ),
            onSubmitted: (_) => loading ? null : onSearch(),
          ),
          const SizedBox(height: 6),
          Text(
            t.location.place_note,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          for (final place in results)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(place.name),
              subtitle: Text(
                [place.admin1, place.country].whereType<String>().join(', '),
              ),
              onTap: () => onSelect(place),
            ),
        ],
      ),
    );
  }
}

/// Alternative option: let the device GPS fill in the location.
class _GpsCard extends StatelessWidget {
  const _GpsCard({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: loading ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.my_location, color: cs.primary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.location.use_gps,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.location.gps_sub,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// A centred "or" between the two location options.
class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            context.t.location.or,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
