import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
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
  int _matchIndex = 1;

  static final _fromController = TextEditingController(text: 'Uttara Sector 4, Dhaka');
  static final _toController = TextEditingController(text: 'Motijheel, Dhaka');

  static const _vehicles = ['🚗 Car', '🏍 Bike ok', '🛺 CNG ok'];
  static const _genders = ['Any gender', 'Female only', 'Male only'];
  static const _walking = ['200 m', '500 m', '1 km'];
  static const _match = ['70%+', '80%+', '90%+'];

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        children: [
          MobilePageHeader(
            title: 'Find a Ride',
            subtitle: 'Refine your search',
            onBack: () => context.pop(),
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
                  controller: _fromController,
                ),
                const SizedBox(height: 8),
                SamewayTextField(
                  label: 'To',
                  icon: '🏢',
                  controller: _toController,
                ),
                const SizedBox(height: 20),
                const SectionHeader('VEHICLE TYPE'),
                const SizedBox(height: 10),
                _FilterChipRow(
                  options: _vehicles,
                  selectedIndex: _vehicleIndex,
                  onSelected: (i) => setState(() => _vehicleIndex = i),
                ),
                const SizedBox(height: 20),
                const SectionHeader('GENDER PREFERENCE'),
                const SizedBox(height: 10),
                _FilterChipRow(
                  options: _genders,
                  selectedIndex: _genderIndex,
                  onSelected: (i) => setState(() => _genderIndex = i),
                ),
                const SizedBox(height: 20),
                const SectionHeader('MAX WALKING DISTANCE'),
                const SizedBox(height: 10),
                _FilterChipRow(
                  options: _walking,
                  selectedIndex: _walkingIndex,
                  onSelected: (i) => setState(() => _walkingIndex = i),
                ),
                const SizedBox(height: 20),
                const SectionHeader('MIN ROUTE MATCH %'),
                const SizedBox(height: 10),
                _FilterChipRow(
                  options: _match,
                  selectedIndex: _matchIndex,
                  onSelected: (i) => setState(() => _matchIndex = i),
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

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(options.length, (index) {
        return GestureDetector(
          onTap: () => onSelected(index),
          child: PreferenceChip(
            label: options[index],
            selected: index == selectedIndex,
          ),
        );
      }),
    );
  }
}
