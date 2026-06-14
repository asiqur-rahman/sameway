import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';
import 'package:sameway/features/home/presentation/widgets/home_widgets.dart';

class SearchFiltersScreen extends StatefulWidget {
  const SearchFiltersScreen({super.key});

  @override
  State<SearchFiltersScreen> createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen> {
  int _vehicleIndex = 0;
  int _genderIndex = 0;
  int _walkingIndex = 1;

  static final _fromController = TextEditingController();
  static final _toController = TextEditingController();

  static const _vehicles = ['Any', 'Car only', 'Bike ok'];
  static const _genders = ['No preference', 'Same gender'];
  static const _walking = ['5 min', '10 min', '15 min'];

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          MobilePageHeader(
            title: 'Find a Ride',
            subtitle: 'Refine your search',
            backFallback: AppRoutes.home,
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
                SamewayTextField(
                  label: 'From',
                  icon: '📍',
                  hint: AppPlaceholders.from,
                  controller: _fromController,
                ),
                const SizedBox(height: 8),
                SamewayTextField(
                  label: 'To',
                  icon: '🏢',
                  hint: AppPlaceholders.to,
                  controller: _toController,
                ),
                const SizedBox(height: 20),
                const SectionHeader('VEHICLE TYPE'),
                const SizedBox(height: 10),
                _VehicleFilterRow(
                  options: _vehicles,
                  selectedIndex: _vehicleIndex,
                  onSelected: (i) => setState(() => _vehicleIndex = i),
                ),
                const SizedBox(height: 20),
                const SectionHeader('GENDER PREFERENCE'),
                const SizedBox(height: 10),
                _GenderFilterRow(
                  options: _genders,
                  selectedIndex: _genderIndex,
                  onSelected: (i) => setState(() => _genderIndex = i),
                ),
                const SizedBox(height: 20),
                const SectionHeader('MAX WALKING DISTANCE'),
                const SizedBox(height: 10),
                _VehicleFilterRow(
                  options: _walking,
                  selectedIndex: _walkingIndex,
                  onSelected: (i) => setState(() => _walkingIndex = i),
                ),
                const SizedBox(height: 16),
                const InfoBanner(
                  emoji: '📍',
                  text:
                      'SameWay matches routes within ±500 m of your commute — no exact A→B needed.',
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
            child: SamewayPrimaryButton(
              label: 'Search Rides',
              onPressed: () => context.push(AppRoutes.searchResults),
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
            padding: EdgeInsets.only(left: index == 0 ? 0 : 4, right: index == options.length - 1 ? 0 : 4),
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
            padding: EdgeInsets.only(left: index == 0 ? 0 : 4, right: index == options.length - 1 ? 0 : 4),
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
