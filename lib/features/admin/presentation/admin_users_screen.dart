import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/widgets/admin_scaffold.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'User Management',
      breadcrumb: 'Admin / Users',
      selectedNav: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ALL USERS',
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
                headers: ['Name', 'Email', 'Status', 'Rides', 'Rating'],
                rows: [
                  ['Rafiq Ahmed', 'rafiq@grameenphone.com', 'Verified', '12', '4.9'],
                  ['Karim Rahman', 'karim@grameenphone.com', 'Verified', '48', '4.8'],
                  ['Sadia Khan', 'sadia@grameenphone.com', 'Pending', '0', '—'],
                  ['Tanvir Hossain', 'tanvir@banglalink.net', 'Pending', '0', '—'],
                  ['Nusrat Jahan', 'nusrat@brac.net', 'Verified', '6', '4.7'],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
