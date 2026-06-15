import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/session/app_data_store.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/theme/app_typography.dart';
import 'package:sameway/core/utils/commute_time_format.dart';
import 'package:sameway/core/widgets/sameway_primary_button.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';
import 'package:sameway/core/widgets/sameway_ui_kit.dart';

class PostRideFilledScreen extends StatefulWidget {
  const PostRideFilledScreen({super.key});

  @override
  State<PostRideFilledScreen> createState() => _PostRideFilledScreenState();
}

class _PostRideFilledScreenState extends State<PostRideFilledScreen> {
  static const _repeatOptions = ['Once', 'Daily', 'Weekdays'];

  @override
  void initState() {
    super.initState();
    _ensureDraftDefaults();
  }

  Future<void> _ensureDraftDefaults() async {
    final draft = AppDataStore.instance.postRideDraft;
    final vehicle = AppSession.instance.currentUser?.vehicle;
    await AppDataStore.instance.updatePostRideDraft((d) {
      d.dateLabel ??= DateFormat('EEE, MMM d').format(DateTime.now());
      d.departTime ??= vehicle?.usuallyLeave.trim().isNotEmpty == true
          ? vehicle!.usuallyLeave
          : '8:30 AM';
      if (d.seats < 1) d.seats = vehicle?.seats ?? 2;
    });
    if (draft.repeat.isEmpty) {
      await AppDataStore.instance.updatePostRideDraft((d) => d.repeat = 'Weekdays');
    }
  }

  int get _repeatIndex {
    final repeat = AppDataStore.instance.postRideDraft.repeat;
    final index = _repeatOptions.indexOf(repeat);
    return index >= 0 ? index : 2;
  }

  Future<void> _pickDate() async {
    final draft = AppDataStore.instance.postRideDraft;
    final initial = draft.dateLabel != null
        ? DateFormat('EEE, MMM d').parse(draft.dateLabel!)
        : DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked == null) return;
    await AppDataStore.instance.updatePostRideDraft(
      (d) => d.dateLabel = DateFormat('EEE, MMM d').format(picked),
    );
  }

  Future<void> _pickTime() async {
    final draft = AppDataStore.instance.postRideDraft;
    final picked = await showTimePicker(
      context: context,
      initialTime:
          CommuteTimeFormat.parse(draft.departTime) ?? const TimeOfDay(hour: 8, minute: 30),
    );
    if (picked == null) return;
    await AppDataStore.instance.updatePostRideDraft(
      (d) => d.departTime = CommuteTimeFormat.format(picked),
    );
  }

  Future<void> _postRide() async {
    try {
      await AppDataStore.instance.publishPostedRide();
      if (!mounted) return;
      context.go(AppRoutes.incomingRequests);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppDataStore.instance,
      builder: (context, _) {
        final draft = AppDataStore.instance.postRideDraft;
        final start = draft.startAddress ?? 'Start';
        final end = draft.endAddress ?? 'End';
        final segmentTip = draft.stops.isEmpty
            ? 'Riders searching along your full route will discover your ride.'
            : '${1 + draft.stops.length} segments created. Riders searching partial routes will also discover your ride.';

        return SamewayScreen(
          child: Column(
            children: [
              const MobilePageHeader(
                title: 'Post a Ride',
                backFallback: AppRoutes.routeConfirmed,
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
                    MapPlaceholder(
                      height: 130,
                      postRideShell: true,
                      showRoute: true,
                      startLabel: start.split(',').first.trim(),
                      endLabel: end.split(',').first.trim(),
                      hint: 'Custom multi-stop route',
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader('YOUR ROUTE'),
                    const SizedBox(height: 12),
                    PostRideRoutePoint(sectionLabel: 'START', title: start),
                    for (final stop in draft.stops) ...[
                      const SizedBox(height: 8),
                      PostRideRoutePoint(sectionLabel: 'STOP', title: stop),
                    ],
                    const SizedBox(height: 8),
                    PostRideRoutePoint(sectionLabel: 'END', title: end),
                    const SizedBox(height: 12),
                    RouteTipBanner(text: segmentTip),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: PostRideValueField(
                            label: 'DATE',
                            emoji: '📅',
                            value: draft.dateLabel ?? 'Today',
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PostRideValueField(
                            label: 'TIME',
                            emoji: '⏰',
                            value: draft.departTime ?? '8:30 AM',
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('REPEAT', style: AppTypography.routeSectionLabel),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        for (var index = 0; index < _repeatOptions.length; index++) ...[
                          if (index > 0) const SizedBox(width: 8),
                          Expanded(
                            child: PostRideRepeatChip(
                              label: _repeatOptions[index],
                              selected: _repeatIndex == index,
                              onTap: () => AppDataStore.instance.updatePostRideDraft(
                                (d) => d.repeat = _repeatOptions[index],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    PostRideSeatsStepper(
                      value: draft.seats,
                      onDecrement: () {
                        if (draft.seats > 1) {
                          AppDataStore.instance.updatePostRideDraft((d) => d.seats--);
                        }
                      },
                      onIncrement: () {
                        if (draft.seats < 4) {
                          AppDataStore.instance.updatePostRideDraft((d) => d.seats++);
                        }
                      },
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
                  label: 'Post Ride',
                  textStyle: AppTypography.buttonDark,
                  isLoading: AppDataStore.instance.isPublishing,
                  onPressed:
                      AppDataStore.instance.isPublishing ? null : _postRide,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
