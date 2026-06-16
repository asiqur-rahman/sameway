import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/maps/sameway_map_view.dart';
import 'package:sameway/core/models/map_location.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_banner.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class PickEndLocationScreen extends StatefulWidget {
  const PickEndLocationScreen({super.key});

  @override
  State<PickEndLocationScreen> createState() => _PickEndLocationScreenState();
}

class _PickEndLocationScreenState extends State<PickEndLocationScreen> {
  final _searchController = TextEditingController();
  String? _selected;
  MapLocation? _pinned;

  @override
  void initState() {
    super.initState();
    _selected = AppDataStore.instance.postRideDraft.endAddress;
    if (_selected != null) _searchController.text = _selected!;
    final draft = AppDataStore.instance.postRideDraft;
    if (draft.endLat != null && draft.endLng != null && _selected != null) {
      _pinned = MapLocation(
        address: _selected!,
        lat: draft.endLat!,
        lng: draft.endLng!,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SavedPlace> _destinations() {
    final user = AppSession.instance.currentUser;
    final places = <_SavedPlace>[];
    if (user?.officeAddress?.trim().isNotEmpty == true) {
      places.add(_SavedPlace(emoji: '🏢', title: 'Office', subtitle: user!.officeAddress!));
    }
    if (user?.homeAddress?.trim().isNotEmpty == true) {
      places.add(_SavedPlace(emoji: '🏠', title: 'Home', subtitle: user!.homeAddress!));
    }
    final draft = AppDataStore.instance.postRideDraft;
    if (draft.startAddress?.trim().isNotEmpty == true) {
      places.add(_SavedPlace(emoji: '🕐', title: 'Recent', subtitle: draft.startAddress!));
    }
    return places;
  }

  Future<void> _saveAndGo(String route) async {
    final address = _searchController.text.trim();
    if (address.isEmpty) {
      SamewayBanner.showWarning(context, 'Choose or enter a destination');
      return;
    }
    await AppDataStore.instance.updatePostRideDraft((d) {
      d.endAddress = address;
      final user = AppSession.instance.currentUser;
      if (_selected == user?.officeAddress) {
        d.endLat = user?.officeLat;
        d.endLng = user?.officeLng;
      } else if (_selected == user?.homeAddress) {
        d.endLat = user?.homeLat;
        d.endLng = user?.homeLng;
      }
    });
    if (!mounted) return;
    context.push(route);
  }

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations();

    return SamewayScreen(
      child: Column(
        children: [
          const MobilePageHeader(
            title: 'Choose End Location',
            backFallback: AppRoutes.pickStart,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                0,
                AppSpacing.screenHorizontal,
                24,
              ),
              children: [
                const MapKeyBanner(),
                MapPlaceholder(
                  height: 400,
                  postRideShell: true,
                  hint: 'Drag the map to adjust your destination pin',
                  pickerMode: true,
                  pickerInitial: _pinned,
                  showMyLocation: true,
                  onMapPicked: (location) {
                    setState(() {
                      _pinned = location;
                      _selected = location.address;
                      _searchController.text = location.address;
                    });
                    AppDataStore.instance.updatePostRideDraft((d) {
                      d.endLat = location.lat;
                      d.endLng = location.lng;
                      d.endAddress = location.address;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SamewayTextField(
                  label: 'Search',
                  hint: AppPlaceholders.searchDestination,
                  icon: '🔍',
                  controller: _searchController,
                ),
                if (destinations.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const SectionHeader('SAVED DESTINATIONS'),
                  const SizedBox(height: 10),
                  ...destinations.map(
                    (place) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DestinationTile(
                        place: place,
                        selected: _selected == place.subtitle,
                        onTap: () {
                          setState(() {
                            _selected = place.subtitle;
                            _searchController.text = place.subtitle;
                          });
                        },
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () => _saveAndGo(AppRoutes.routeConfirmed),
                    child: Text(
                      'Skip — no extra stop needed',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              0,
              AppSpacing.screenHorizontal,
              24,
            ),
            child: SamewayDarkButton(
              label: 'Confirm Destination',
              textStyle: AppTypography.buttonDark,
              onPressed: () => _saveAndGo(AppRoutes.addStop),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedPlace {
  const _SavedPlace({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final _SavedPlace place;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryTint7 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(place.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    place.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
