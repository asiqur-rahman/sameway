import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/widgets/admin_scaffold.dart';

class AdminVerificationScreen extends StatelessWidget {
  const AdminVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'ID Verification',
      breadcrumb: 'Admin / Verification',
      selectedNav: 1,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PENDING REVIEWS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AdminDataTable(
                headers: ['Name', 'Email', 'Company', 'Submitted', 'Action'],
                rows: [
                  ['Sadia Khan', 'sadia@grameenphone.com', 'Grameenphone', 'Jun 13', 'Review'],
                  ['Tanvir Hossain', 'tanvir@banglalink.net', 'Banglalink', 'Jun 12', 'Review'],
                  ['Nusrat Jahan', 'nusrat@brac.net', 'BRAC', 'Jun 12', 'Review'],
                  ['Imran Ali', 'imran@unilever.com', 'Unilever', 'Jun 11', 'Review'],
                  ['Farhana Begum', 'farhana@gp.com', 'Grameenphone', 'Jun 11', 'Review'],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
