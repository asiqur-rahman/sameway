import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/widgets/admin_scaffold.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Dashboard',
      breadcrumb: 'Admin / Dashboard',
      selectedNav: 0,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                AdminStatCard(label: 'Active Users', value: '1,248', delta: '+12% this week'),
                SizedBox(width: 16),
                AdminStatCard(label: 'Rides Today', value: '342', delta: '+8% vs yesterday'),
                SizedBox(width: 16),
                AdminStatCard(label: 'Pending Verifications', value: '18'),
                SizedBox(width: 16),
                AdminStatCard(label: 'Match Rate', value: '87%', delta: '+3%'),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'RECENT ACTIVITY',
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
                headers: ['Time', 'Event', 'User', 'Details'],
                rows: [
                  ['9:12 AM', 'Ride completed', 'Rafiq Ahmed', 'Uttara → Motijheel'],
                  ['8:45 AM', 'New user signup', 'Tanvir Hossain', 'tanvir@banglalink.net'],
                  ['8:30 AM', 'Ride posted', 'Karim Rahman', 'Uttara → Motijheel · 2 seats'],
                  ['7:55 AM', 'ID submitted', 'Sadia Khan', 'Pending review'],
                  ['7:20 AM', 'Match confirmed', 'Rafiq Ahmed', 'Joined Karim\'s ride'],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
