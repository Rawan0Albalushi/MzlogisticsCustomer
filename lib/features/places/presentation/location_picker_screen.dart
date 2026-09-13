import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/i18n/i18n_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/geo_location.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../data/place_suggestion.dart';
import '../data/places_repository.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.title,
    this.initial,
  });

  final String title;
  final GeoLocation? initial;

  static Future<GeoLocation?> open(
    BuildContext context, {
    required String title,
    GeoLocation? initial,
  }) {
    return Navigator.of(context).push<GeoLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(title: title, initial: initial),
      ),
    );
  }

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _search = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _mapController = MapController();
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = [];
  bool _searching = false;
  bool _resolving = false;
  String? _searchError;
  late LatLng _center;
  GeoLocation? _selected;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null && initial.hasCoordinates) {
      _selected = initial;
      _address.text = initial.address;
      _city.text = initial.city;
      _center = LatLng(initial.lat, initial.lng);
    } else {
      _center = const LatLng(AppConstants.mapDefaultLat, AppConstants.mapDefaultLng);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _address.dispose();
    _city.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _searchError = null;
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () => _searchPlaces(value.trim()));
  }

  Future<void> _searchPlaces(String query) async {
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await ref.read(placesRepositoryProvider).autocomplete(query);
      if (!mounted) return;
      setState(() {
        _suggestions = results;
        _searching = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _suggestions = [];
        _searching = false;
        _searchError = _mapsError(error);
      });
    }
  }

  Future<void> _selectSuggestion(PlaceSuggestion suggestion) async {
    setState(() {
      _resolving = true;
      _suggestions = [];
      _search.text = suggestion.description;
    });
    try {
      final location = await ref.read(placesRepositoryProvider).details(suggestion.placeId);
      if (!mounted) return;
      _applyLocation(location);
    } catch (error) {
      if (!mounted) return;
      setState(() => _searchError = _mapsError(error));
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _dropPin(LatLng point) async {
    setState(() {
      _center = point;
      _resolving = true;
      _suggestions = [];
    });
    _mapController.move(point, AppConstants.mapPlaceZoom);
    try {
      final location = await ref.read(placesRepositoryProvider).reverse(point.latitude, point.longitude);
      if (!mounted) return;
      _applyLocation(
        location?.copyWith(lat: point.latitude, lng: point.longitude) ??
            GeoLocation(
              address: _address.text.trim(),
              city: _city.text.trim(),
              lat: point.latitude,
              lng: point.longitude,
            ),
      );
    } catch (_) {
      if (!mounted) return;
      _applyLocation(
        GeoLocation(
          address: _address.text.trim(),
          city: _city.text.trim(),
          lat: point.latitude,
          lng: point.longitude,
        ),
      );
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  void _applyLocation(GeoLocation location) {
    final point = LatLng(location.lat, location.lng);
    _address.text = location.address;
    if (location.city.isNotEmpty) {
      _city.text = location.city;
    }
    _selected = location.copyWith(
      address: _address.text.trim(),
      city: _city.text.trim(),
    );
    _center = point;
    _mapController.move(point, AppConstants.mapPlaceZoom);
    setState(() {});
  }

  void _confirm() {
    final location = GeoLocation(
      address: _address.text.trim(),
      city: _city.text.trim(),
      lat: _selected?.lat ?? _center.latitude,
      lng: _selected?.lng ?? _center.longitude,
      placeId: _selected?.placeId,
    );
    if (location.address.isEmpty || location.city.isEmpty || !location.hasCoordinates) {
      return;
    }
    Navigator.of(context).pop(location);
  }

  String _mapsError(Object error) {
    final i18n = ref.i18n;
    if (error is ApiException) {
      if (error.statusCode == 503) return i18n.t('location.mapsUnavailable');
      if (error.message == 'network') return i18n.t('common.networkError');
      return error.message;
    }
    return i18n.t('location.searchFailed');
  }

  bool get _canConfirm {
    return _address.text.trim().isNotEmpty &&
        _city.text.trim().isNotEmpty &&
        _selected != null;
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.i18n;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppTextField(
              label: i18n.t('location.searchGoogleMaps'),
              hint: i18n.t('location.searchHint'),
              controller: _search,
              onChanged: _onSearchChanged,
              suffix: _searching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search),
            ),
          ),
          if (_searchError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(_searchError!, style: const TextStyle(color: AppColors.danger)),
              ),
            ),
          if (_suggestions.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined, color: AppColors.amber),
                    title: Text(item.mainText ?? item.description),
                    subtitle: item.secondaryText == null ? null : Text(item.secondaryText!),
                    onTap: _resolving ? null : () => _selectSuggestion(item),
                  );
                },
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: widget.initial == null
                        ? AppConstants.mapCountryZoom
                        : AppConstants.mapPlaceZoom,
                    onTap: (_, point) => _dropPin(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.mz_logistics_customer_app',
                    ),
                    if (_selected != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_selected!.lat, _selected!.lng),
                            width: 40,
                            height: 40,
                            alignment: Alignment.topCenter,
                            child: const Icon(Icons.location_on, color: AppColors.amber, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
                if (_resolving)
                  const Positioned(
                    top: 12,
                    right: 12,
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: IgnorePointer(
                    child: Text(
                      i18n.t('location.dropPinHint'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(color: Colors.white, blurRadius: 8)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Material(
            elevation: 8,
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                children: [
                  AppTextField(
                    label: i18n.t('common.address'),
                    controller: _address,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: i18n.t('common.city'),
                    controller: _city,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${i18n.t('location.coordinates')}: ${formatCoordinates(_selected?.lat ?? _center.latitude, _selected?.lng ?? _center.longitude)}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: i18n.t('location.confirm'),
                    expanded: true,
                    onPressed: _canConfirm && !_resolving ? _confirm : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
