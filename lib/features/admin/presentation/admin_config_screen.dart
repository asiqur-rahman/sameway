import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_placeholders.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/admin_scaffold.dart';
import 'package:sameway/core/widgets/sameway_text_field.dart';

class AdminConfigScreen extends StatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  State<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends State<AdminConfigScreen> {
  final _domainController = TextEditingController();
  bool _autoVerify = true;
  bool _maintenanceMode = false;

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'System Config',
      breadcrumb: 'Admin / Config',
      selectedNav: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DOMAIN ALLOWLIST',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SamewayTextField(
                    label: 'Add domain',
                    hint: AppPlaceholders.domain,
                    controller: _domainController,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DomainChip(label: 'grameenphone.com'),
                      _DomainChip(label: 'banglalink.net'),
                      _DomainChip(label: 'brac.net'),
                      _DomainChip(label: 'unilever.com'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SYSTEM SETTINGS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            _SettingTile(
              title: 'Auto-verify known domains',
              subtitle: 'Skip manual review for allowlisted domains',
              value: _autoVerify,
              onChanged: (v) => setState(() => _autoVerify = v),
            ),
            _SettingTile(
              title: 'Maintenance mode',
              subtitle: 'Block new signups and ride posting',
              value: _maintenanceMode,
              onChanged: (v) => setState(() => _maintenanceMode = v),
            ),
          ],
        ),
      ),
    );
  }
}

class _DomainChip extends StatelessWidget {
  const _DomainChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 13),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
