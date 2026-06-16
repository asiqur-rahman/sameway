import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/api/api_exception.dart';
import 'package:sameway/core/api/repositories/places_repository.dart';
import 'package:sameway/core/api/repositories/rides_repository.dart';
import 'package:sameway/core/session/app_session.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_banner.dart';
import 'package:sameway/core/widgets/sameway_loading.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

class RegularRoutesScreen extends StatefulWidget {
  const RegularRoutesScreen({super.key});

  @override
  State<RegularRoutesScreen> createState() => _RegularRoutesScreenState();
}

class _RegularRoutesScreenState extends State<RegularRoutesScreen> {
  List<RegularRoute> _routes = [];
  bool _loading = true;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (!mounted) return;
    setState(() => refresh ? _refreshing = true : _loading = true);
    try {
      final routes = await RidesRepository.instance.listRegularRoutes();
      if (!mounted) return;
      setState(() {
        _routes = routes;
        _loading = false;
        _refreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
      });
      SamewayBanner.showError(context, e);
    }
  }

  Future<void> _delete(RegularRoute route) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete route?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        content: Text(
          'Remove "${route.displayName}" from your saved routes.',
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await RidesRepository.instance.deleteRegularRoute(route.id);
      if (!mounted) return;
      SamewayBanner.showSuccess(context, 'Route deleted');
      _load();
    } catch (e) {
      if (!mounted) return;
      SamewayBanner.showError(context, e);
    }
  }

  Future<void> _postToday(RegularRoute route) async {
    final now = DateTime.now();
    final timeParts = route.departureTime.split(':');
    final hour = int.tryParse(timeParts.firstOrNull ?? '8') ?? 8;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;
    var departure = DateTime(now.year, now.month, now.day, hour, minute);
    if (departure.isBefore(now)) {
      departure = departure.add(const Duration(days: 1));
    }

    try {
      await RidesRepository.instance.postRideFromRoute(route.id, departure);
      if (!mounted) return;
      SamewayBanner.showSuccess(
        context,
        'Ride posted for ${route.departureTime}',
      );
    } catch (e) {
      if (!mounted) return;
      SamewayBanner.showError(context, e);
    }
  }

  void _showAddRouteSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddRouteSheet(onCreated: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        16,
        AppSpacing.screenHorizontal,
        24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regular Routes',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Save your daily commute — post a ride each morning in one tap.',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => _load(refresh: true),
              child: _loading && !_refreshing
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        RideCardSkeleton(),
                        SizedBox(height: 12),
                        RideCardSkeleton(),
                      ],
                    )
                  : _routes.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 60),
                            Center(
                              child: Column(
                                children: [
                                  const Text('🗺️', style: TextStyle(fontSize: 40)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No saved routes yet.\nAdd your regular commute once\nand post rides every morning in one tap.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.textMuted,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _routes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, index) => _RouteCard(
                            route: _routes[index],
                            onDelete: () => _delete(_routes[index]),
                            onPostToday: () => _postToday(_routes[index]),
                          ),
                        ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 49,
            child: OutlinedButton(
              onPressed: _showAddRouteSheet,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
              ),
              child: Text(
                '＋  Add new route',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Route card ──────────────────────────────────────────────────────────────

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.onDelete,
    required this.onPostToday,
  });

  final RegularRoute route;
  final VoidCallback onDelete;
  final VoidCallback onPostToday;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route.displayName,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            route.scheduleLabel,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: FilledButton(
                    onPressed: onPostToday,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Post for today',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                child: OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(
                    'Delete',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Add route bottom sheet ───────────────────────────────────────────────────

class _AddRouteSheet extends StatefulWidget {
  const _AddRouteSheet({required this.onCreated});

  final VoidCallback onCreated;

  @override
  State<_AddRouteSheet> createState() => _AddRouteSheetState();
}

class _AddRouteSheetState extends State<_AddRouteSheet> {
  final _fromCtl = TextEditingController();
  final _toCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  final _timeCtl = TextEditingController(text: '08:00');

  final Set<int> _days = {1, 2, 3, 4, 5}; // Mon–Fri pre-selected
  int _seats = 1;
  bool _saving = false;

  static const _dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    final user = AppSession.instance.currentUser;
    if (user?.homeAddress?.isNotEmpty == true) _fromCtl.text = user!.homeAddress!;
    if (user?.officeAddress?.isNotEmpty == true) _toCtl.text = user!.officeAddress!;
  }

  @override
  void dispose() {
    _fromCtl.dispose();
    _toCtl.dispose();
    _nameCtl.dispose();
    _timeCtl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final parts = _timeCtl.text.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '8') ?? 8,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null && mounted) {
      setState(() {
        _timeCtl.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _save() async {
    final from = _fromCtl.text.trim();
    final to = _toCtl.text.trim();
    if (from.isEmpty || to.isEmpty) {
      SamewayBanner.show(context, message: 'Enter both locations', type: SamewayBannerType.warning);
      return;
    }
    if (_days.isEmpty) {
      SamewayBanner.show(context, message: 'Select at least one day', type: SamewayBannerType.warning);
      return;
    }

    setState(() => _saving = true);
    try {
      final user = AppSession.instance.currentUser;

      // Resolve lat/lng from session or geocode via API
      final fromCoords = await _resolve(from, user?.homeAddress, user?.homeLat, user?.homeLng);
      final toCoords = await _resolve(to, user?.officeAddress, user?.officeLat, user?.officeLng);

      if (fromCoords == null || toCoords == null) {
        if (!mounted) return;
        setState(() => _saving = false);
        SamewayBanner.show(
          context,
          message: 'Could not locate the address. Try a more specific name.',
          type: SamewayBannerType.error,
        );
        return;
      }

      await RidesRepository.instance.createRegularRoute(
        startAddress: from,
        startLat: fromCoords.$1,
        startLng: fromCoords.$2,
        endAddress: to,
        endLat: toCoords.$1,
        endLng: toCoords.$2,
        scheduleDays: _days.toList()..sort(),
        departureTime: _timeCtl.text,
        defaultSeats: _seats,
        name: _nameCtl.text.trim().isEmpty ? null : _nameCtl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
      SamewayBanner.showSuccess(context, 'Route saved');
      widget.onCreated();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      SamewayBanner.showError(context, e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      SamewayBanner.showError(context, e);
    }
  }

  Future<(double, double)?> _resolve(
    String address,
    String? savedAddress,
    double? savedLat,
    double? savedLng,
  ) async {
    if (savedAddress == address && savedLat != null && savedLng != null) {
      return (savedLat, savedLng);
    }
    try {
      final loc = await PlacesRepository.instance.geocodeAddress(address);
      return (loc.lat, loc.lng);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 24, 20, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'New regular route',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _SheetLabel('Route name (optional)'),
            _SheetField(controller: _nameCtl, hint: 'e.g. Morning commute'),
            const SizedBox(height: 12),
            _SheetLabel('From'),
            _SheetField(controller: _fromCtl, hint: 'Home or pickup address'),
            const SizedBox(height: 12),
            _SheetLabel('To'),
            _SheetField(controller: _toCtl, hint: 'Office or destination'),
            const SizedBox(height: 16),
            _SheetLabel('Days'),
            const SizedBox(height: 8),
            Row(
              children: List.generate(7, (i) {
                final isOn = _days.contains(i);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      isOn ? _days.remove(i) : _days.add(i);
                    }),
                    child: Container(
                      margin: EdgeInsets.only(right: i < 6 ? 4 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isOn ? AppColors.primary : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isOn ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _dayNames[i],
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isOn ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SheetLabel('Departure time'),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 18, color: AppColors.textMuted),
                              const SizedBox(width: 8),
                              Text(
                                _timeCtl.text,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SheetLabel('Seats'),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StepperBtn(
                          icon: Icons.remove,
                          onTap: _seats > 1 ? () => setState(() => _seats--) : null,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            '$_seats',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _StepperBtn(
                          icon: Icons.add,
                          onTap: _seats < 4 ? () => setState(() => _seats++) : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 49,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Save route',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 0.3,
        ),
      );
}

class _SheetField extends StatelessWidget {
  const _SheetField({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: controller,
          style: GoogleFonts.inter(fontSize: 14),
          decoration: InputDecoration(
            border: InputBorder.none,
            isDense: true,
            hintText: hint,
            hintStyle: GoogleFonts.inter(fontSize: 14, color: AppColors.textMuted),
          ),
        ),
      );
}

class _StepperBtn extends StatelessWidget {
  const _StepperBtn({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(
            icon,
            size: 18,
            color: onTap != null ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      );
}
