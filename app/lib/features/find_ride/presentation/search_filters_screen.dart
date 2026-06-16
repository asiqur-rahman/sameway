import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/widgets/sameway_banner.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/find_ride/find_ride_flow.dart';
import 'package:sameway/features/find_ride/presentation/widgets/find_ride_widgets.dart';
import 'package:sameway/features/home/presentation/widgets/home_widgets.dart';

/// Wireframe v2 — ScreenSearchRides: map-first search with filters.
class SearchFiltersScreen extends StatefulWidget {
  const SearchFiltersScreen({super.key});

  @override
  State<SearchFiltersScreen> createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  final _dateController = TextEditingController();
  final _arriveController = TextEditingController();

  late int _vehicleIndex;
  late int _genderIndex;
  late int _walkMinutes;
  late int _minMatchIndex;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    final flow = FindRideFlow.instance;
    if (flow.from.isEmpty && flow.to.isEmpty) {
      flow.hydrateFromSession();
    }
    _fromController.text = flow.from;
    _toController.text = flow.to;
    _dateController.text = flow.dateLabel;
    _arriveController.text = flow.arriveBy;
    _vehicleIndex = flow.vehicleIndex;
    _genderIndex = flow.genderIndex;
    _walkMinutes = flow.maxWalkMinutes;
    _minMatchIndex = flow.minMatchIndex;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _arriveController.dispose();
    super.dispose();
  }

  Future<void> _pickFrom() async {
    final flow = FindRideFlow.instance;
    final picked = await showHomeLocationPicker(
      context,
      title: 'From — where are you leaving?',
      initial: _fromController.text,
      initialLat: flow.fromLat,
      initialLng: flow.fromLng,
      preferCurrentLocation: true,
    );
    if (picked != null && picked.isValid && mounted) {
      _fromController.text = picked.address;
      flow.setFromLocation(picked);
    }
  }

  Future<void> _pickTo() async {
    final flow = FindRideFlow.instance;
    final picked = await showHomeLocationPicker(
      context,
      title: 'To — where are you going?',
      initial: _toController.text,
      initialLat: flow.toLat,
      initialLng: flow.toLng,
    );
    if (picked != null && picked.isValid && mounted) {
      _toController.text = picked.address;
      flow.setToLocation(picked);
    }
  }

  void _swapFromTo() {
    FindRideFlow.instance.swapEndpoints();
    final flow = FindRideFlow.instance;
    _fromController.text = flow.from;
    _toController.text = flow.to;
  }

  Future<void> _search() async {
    final flow = FindRideFlow.instance;
    flow
      ..from = _fromController.text.trim()
      ..to = _toController.text.trim()
      ..dateLabel = _dateController.text.trim()
      ..arriveBy = _arriveController.text.trim()
      ..vehicleIndex = _vehicleIndex
      ..genderIndex = _genderIndex
      ..maxWalkMinutes = _walkMinutes
      ..minMatchIndex = _minMatchIndex
      ..vehicleFilter = 'All';

    setState(() => _searching = true);
    try {
      await flow.ensureSearchCoordinates();
      await flow.persistMatchedSavedPlaces();
      if (!mounted) return;
      context.push(AppRoutes.searchResults);
    } catch (e) {
      if (!mounted) return;
      SamewayBanner.showError(context, e);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          const MobilePageHeader(
            title: 'Find a Ride',
            backFallback: AppRoutes.home,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                14,
                AppSpacing.screenHorizontal,
                24,
              ),
              children: [
                FindRouteFieldStack(
                  fromController: _fromController,
                  toController: _toController,
                  onFromTap: _pickFrom,
                  onToTap: _pickTo,
                  onSwap: _swapFromTo,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompactField(
                        label: 'Date',
                        icon: '📅',
                        controller: _dateController,
                        hint: AppPlaceholders.date,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CompactField(
                        label: 'Arrive by',
                        icon: '⏰',
                        controller: _arriveController,
                        hint: AppPlaceholders.arriveBy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SectionHeader('VEHICLE TYPE'),
                const SizedBox(height: 10),
                _VehicleFilterRow(
                  options: FindRideFlow.vehicleOptions,
                  selectedIndex: _vehicleIndex,
                  onSelected: (i) => setState(() => _vehicleIndex = i),
                ),
                const SizedBox(height: 20),
                const SectionHeader('GENDER PREFERENCE'),
                const SizedBox(height: 10),
                _GenderFilterRow(
                  options: FindRideFlow.genderOptions,
                  selectedIndex: _genderIndex,
                  onSelected: (i) => setState(() => _genderIndex = i),
                ),
                const SizedBox(height: 20),
                const SectionHeader('MAX WALKING DISTANCE TO PICKUP'),
                const SizedBox(height: 10),
                FindWalkDistanceCard(
                  minutes: _walkMinutes,
                  onChanged: (v) => setState(() => _walkMinutes = v),
                ),
                const SizedBox(height: 20),
                const SectionHeader('MINIMUM ROUTE MATCH'),
                const SizedBox(height: 10),
                FindMinMatchRow(
                  selectedIndex: _minMatchIndex,
                  onSelected: (i) => setState(() => _minMatchIndex = i),
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
              label: 'Search Rides',
              textStyle: AppTypography.buttonDark,
              isLoading: _searching,
              onPressed: _searching ? null : _search,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactField extends StatelessWidget {
  const _CompactField({
    required this.label,
    required this.icon,
    required this.controller,
    required this.hint,
  });

  final String label;
  final String icon;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: AppTypography.sectionAccent(color: AppColors.textMuted),
                ),
                TextField(
                  controller: controller,
                  style: AppTypography.dateTimeValue,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: AppTypography.dateTimeValue.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleFilterRow extends StatelessWidget {
  const _VehicleFilterRow({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == options.length - 1 ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: FilterSegmentChip(
                label: options[index],
                selected: index == selectedIndex,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _GenderFilterRow extends StatelessWidget {
  const _GenderFilterRow({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == options.length - 1 ? 0 : 4,
            ),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: GenderFilterChip(
                label: options[index],
                selected: index == selectedIndex,
              ),
            ),
          ),
        );
      }),
    );
  }
}
