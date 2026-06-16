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
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class PickStartLocationScreen extends StatefulWidget {
  const PickStartLocationScreen({super.key});

  @override
  State<PickStartLocationScreen> createState() => _PickStartLocationScreenState();
}

class _PickStartLocationScreenState extends State<PickStartLocationScreen> {
  final _searchController = TextEditingController();
  String? _selected;
  MapLocation? _pinned;

  @override
  void initState() {
    super.initState();
    _selected = AppDataStore.instance.postRideDraft.startAddress;
    if (_selected != null) _searchController.text = _selected!;
    final draft = AppDataStore.instance.postRideDraft;
    if (draft.startLat != null && draft.startLng != null && _selected != null) {
      _pinned = MapLocation(
        address: _selected!,
        lat: draft.startLat!,
        lng: draft.startLng!,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_SavedPlace> _savedPlaces() {
    final user = AppSession.instance.currentUser;
    final places = <_SavedPlace>[];
    if (user?.homeAddress?.trim().isNotEmpty == true) {
      places.add(_SavedPlace(emoji: '🏠', title: 'Home', subtitle: user!.homeAddress!));
    }
    if (user?.officeAddress?.trim().isNotEmpty == true) {
      places.add(_SavedPlace(emoji: '🏢', title: 'Office', subtitle: user!.officeAddress!));
    }
    final draft = AppDataStore.instance.postRideDraft;
    if (draft.endAddress?.trim().isNotEmpty == true) {
      places.add(_SavedPlace(emoji: '🕐', title: 'Recent', subtitle: draft.endAddress!));
    }
    return places;
  }

  Future<void> _confirm() async {
    final address = _searchController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose or enter a start location')),
      );
      return;
    }
    await AppDataStore.instance.updatePostRideDraft((d) {
      d.startAddress = address;
      final user = AppSession.instance.currentUser;
      if (_selected == user?.homeAddress) {
        d.startLat = user?.homeLat;
        d.startLng = user?.homeLng;
      } else if (_selected == user?.officeAddress) {
        d.startLat = user?.officeLat;
        d.startLng = user?.officeLng;
      }
    });
    if (!mounted) return;
    context.push(AppRoutes.pickEnd);
  }

  @override
  Widget build(BuildContext context) {
    final savedPlaces = _savedPlaces();

    return SamewayScreen(
      child: Column(
        children: [
          const MobilePageHeader(
            title: 'Choose Start Location',
            backFallback: AppRoutes.postRideEmpty,
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
                  hint: 'Drag the map to adjust your start pin',
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
                      d.startLat = location.lat;
                      d.startLng = location.lng;
                      d.startAddress = location.address;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SamewayTextField(
                  label: 'Search',
                  hint: AppPlaceholders.searchStart,
                  icon: '🔍',
                  controller: _searchController,
                ),
                if (savedPlaces.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const SectionHeader('SAVED PLACES'),
                  const SizedBox(height: 10),
                  ...savedPlaces.map(
                    (place) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SavedPlaceTile(
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
              label: 'Confirm Start Location',
              textStyle: AppTypography.buttonDark,
              onPressed: _confirm,
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

class _SavedPlaceTile extends StatelessWidget {
  const _SavedPlaceTile({
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
