import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/core/theme/app_colors.dart';
import 'package:sameway/core/theme/app_spacing.dart';
import 'package:sameway/core/widgets/sameway_screen.dart';

class ScreenCatalogScreen extends StatelessWidget {
  const ScreenCatalogScreen({super.key});

  static const _routes = [
    _CatalogEntry('Splash', AppRoutes.splash),
    _CatalogEntry('Sign Up', AppRoutes.signUp),
    _CatalogEntry('Profile Setup · Step 1', AppRoutes.profileSetup),
    _CatalogEntry('Commute Details · Step 2', AppRoutes.commuteDetails),
    _CatalogEntry('Work Verification · Step 3', AppRoutes.workVerification),
    _CatalogEntry('Vehicle (drivers only)', AppRoutes.vehicle),
    _CatalogEntry('Work Location (legacy)', AppRoutes.workLocation),
    _CatalogEntry('Pick Office Map', AppRoutes.pickOfficeMap),
    _CatalogEntry('Office ID', AppRoutes.officeId),
    _CatalogEntry('Home', AppRoutes.home),
    _CatalogEntry('My Rides', AppRoutes.rides),
    _CatalogEntry('Chat', AppRoutes.chat),
    _CatalogEntry('Profile Tab', AppRoutes.profile),
    _CatalogEntry('Post Ride Empty', AppRoutes.postRideEmpty),
    _CatalogEntry('Pick Start', AppRoutes.pickStart),
    _CatalogEntry('Pick End', AppRoutes.pickEnd),
    _CatalogEntry('Add Stop', AppRoutes.addStop),
    _CatalogEntry('Route Confirmed', AppRoutes.routeConfirmed),
    _CatalogEntry('Post Ride Filled', AppRoutes.postRideFilled),
    _CatalogEntry('Incoming Requests', AppRoutes.incomingRequests),
    _CatalogEntry('Search Filters', AppRoutes.searchFilters),
    _CatalogEntry('Search Results', AppRoutes.searchResults),
    _CatalogEntry('Ride Detail', AppRoutes.rideDetail),
    _CatalogEntry('Request Sent', AppRoutes.requestSent),
    _CatalogEntry('Chat Conversation', AppRoutes.chatConversation),
    _CatalogEntry('My Profile', AppRoutes.myProfile),
    _CatalogEntry('Regular Routes', AppRoutes.regularRoutes),
    _CatalogEntry('Reminder Settings', AppRoutes.reminderSettings),
    _CatalogEntry('Departure In', AppRoutes.departureIn),
    _CatalogEntry('Tap to Notify', AppRoutes.tapToNotify),
    _CatalogEntry('After Heading Out', AppRoutes.afterHeadingOut),
    _CatalogEntry('Pickup In', AppRoutes.pickupIn),
    _CatalogEntry('Let Driver Know', AppRoutes.letDriverKnow),
    _CatalogEntry('Notification Centre', AppRoutes.notificationCentre),
    _CatalogEntry('Admin Dashboard', AppRoutes.adminDashboard),
    _CatalogEntry('Admin Verification', AppRoutes.adminVerification),
    _CatalogEntry('Admin Users', AppRoutes.adminUsers),
    _CatalogEntry('Admin Config', AppRoutes.adminConfig),
    _CatalogEntry('Web Landing', AppRoutes.webLanding),
    _CatalogEntry('Web Sign In', AppRoutes.webSignIn),
    _CatalogEntry('Web Dashboard', AppRoutes.webDashboard),
    _CatalogEntry('Web Find Ride', AppRoutes.webFindRide),
    _CatalogEntry('Web Post Ride', AppRoutes.webPostRide),
    _CatalogEntry('Web My Rides', AppRoutes.webMyRides),
    _CatalogEntry('Web Profile', AppRoutes.webProfile),
  ];

  @override
  Widget build(BuildContext context) {
    return SamewayScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              'Screen Catalog',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _routes.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                final entry = _routes[index];
                return ListTile(
                  onTap: () => context.go(entry.route),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenHorizontal,
                    vertical: 2,
                  ),
                  title: Text(
                    entry.label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    entry.route,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogEntry {
  const _CatalogEntry(this.label, this.route);

  final String label;
  final String route;
}
