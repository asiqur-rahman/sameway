import 'package:go_router/go_router.dart';
import 'package:sameway/core/routes/app_routes.dart';
import 'package:sameway/features/admin/presentation/admin_config_screen.dart';
import 'package:sameway/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:sameway/features/admin/presentation/admin_users_screen.dart';
import 'package:sameway/features/admin/presentation/admin_verification_screen.dart';
import 'package:sameway/features/dev/presentation/screen_catalog_screen.dart';
import 'package:sameway/features/find_ride/presentation/ride_detail_screen.dart';
import 'package:sameway/features/find_ride/presentation/search_filters_screen.dart';
import 'package:sameway/features/find_ride/presentation/search_results_screen.dart';
import 'package:sameway/features/home/presentation/home_screen.dart';
import 'package:sameway/features/match/presentation/chat_conversation_screen.dart';
import 'package:sameway/features/match/presentation/chat_list_screen.dart';
import 'package:sameway/features/match/presentation/my_profile_screen.dart';
import 'package:sameway/features/match/presentation/my_rides_screen.dart';
import 'package:sameway/features/match/presentation/regular_routes_screen.dart';
import 'package:sameway/features/match/presentation/request_sent_screen.dart';
import 'package:sameway/features/offer_ride/presentation/add_stop_screen.dart';
import 'package:sameway/features/offer_ride/presentation/incoming_requests_screen.dart';
import 'package:sameway/features/offer_ride/presentation/pick_end_location_screen.dart';
import 'package:sameway/features/offer_ride/presentation/pick_start_location_screen.dart';
import 'package:sameway/features/offer_ride/presentation/post_ride_empty_screen.dart';
import 'package:sameway/features/offer_ride/presentation/post_ride_filled_screen.dart';
import 'package:sameway/features/offer_ride/presentation/route_confirmed_screen.dart';
import 'package:sameway/features/onboarding/presentation/office_id_screen.dart';
import 'package:sameway/features/onboarding/presentation/profile_setup_screen.dart';
import 'package:sameway/features/onboarding/presentation/sign_up_screen.dart';
import 'package:sameway/features/onboarding/presentation/splash_screen.dart';
import 'package:sameway/features/onboarding/presentation/vehicle_screen.dart';
import 'package:sameway/features/onboarding/presentation/work_location_screen.dart';
import 'package:sameway/features/ride_day/presentation/after_heading_out_screen.dart';
import 'package:sameway/features/ride_day/presentation/departure_in_screen.dart';
import 'package:sameway/features/ride_day/presentation/let_driver_know_screen.dart';
import 'package:sameway/features/ride_day/presentation/notification_centre_screen.dart';
import 'package:sameway/features/ride_day/presentation/pickup_in_screen.dart';
import 'package:sameway/features/ride_day/presentation/reminder_settings_screen.dart';
import 'package:sameway/features/web/presentation/web_dashboard_screen.dart';
import 'package:sameway/features/web/presentation/web_find_ride_screen.dart';
import 'package:sameway/features/web/presentation/web_landing_screen.dart';
import 'package:sameway/features/web/presentation/web_my_rides_screen.dart';
import 'package:sameway/features/web/presentation/web_post_ride_screen.dart';
import 'package:sameway/features/web/presentation/web_profile_screen.dart';
import 'package:sameway/features/web/presentation/web_sign_in_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(path: AppRoutes.signUp, builder: (_, _) => SignUpScreen()),
    GoRoute(path: AppRoutes.profileSetup, builder: (_, _) => const ProfileSetupScreen()),
    GoRoute(path: AppRoutes.vehicle, builder: (_, _) => VehicleScreen()),
    GoRoute(path: AppRoutes.workLocation, builder: (_, _) => WorkLocationScreen()),
    GoRoute(path: AppRoutes.officeId, builder: (_, _) => const OfficeIdScreen()),
    GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
    GoRoute(path: AppRoutes.rides, builder: (_, _) => const MyRidesScreen()),
    GoRoute(path: AppRoutes.chat, builder: (_, _) => const ChatListScreen()),
    GoRoute(path: AppRoutes.profile, builder: (_, _) => const MyProfileScreen()),
    GoRoute(path: AppRoutes.postRideEmpty, builder: (_, _) => const PostRideEmptyScreen()),
    GoRoute(path: AppRoutes.pickStart, builder: (_, _) => PickStartLocationScreen()),
    GoRoute(path: AppRoutes.pickEnd, builder: (_, _) => PickEndLocationScreen()),
    GoRoute(path: AppRoutes.addStop, builder: (_, _) => AddStopScreen()),
    GoRoute(path: AppRoutes.routeConfirmed, builder: (_, _) => const RouteConfirmedScreen()),
    GoRoute(path: AppRoutes.postRideFilled, builder: (_, _) => const PostRideFilledScreen()),
    GoRoute(path: AppRoutes.incomingRequests, builder: (_, _) => const IncomingRequestsScreen()),
    GoRoute(path: AppRoutes.searchFilters, builder: (_, _) => const SearchFiltersScreen()),
    GoRoute(path: AppRoutes.searchResults, builder: (_, _) => const SearchResultsScreen()),
    GoRoute(path: AppRoutes.rideDetail, builder: (_, _) => const RideDetailScreen()),
    GoRoute(path: AppRoutes.requestSent, builder: (_, _) => const RequestSentScreen()),
    GoRoute(path: AppRoutes.chatConversation, builder: (_, _) => const ChatConversationScreen()),
    GoRoute(path: AppRoutes.myProfile, builder: (_, _) => const MyProfileScreen()),
    GoRoute(path: AppRoutes.regularRoutes, builder: (_, _) => const RegularRoutesScreen()),
    GoRoute(path: AppRoutes.reminderSettings, builder: (_, _) => const ReminderSettingsScreen()),
    GoRoute(path: AppRoutes.departureIn, builder: (_, _) => const DepartureInScreen()),
    GoRoute(path: AppRoutes.afterHeadingOut, builder: (_, _) => const AfterHeadingOutScreen()),
    GoRoute(path: AppRoutes.pickupIn, builder: (_, _) => const PickupInScreen()),
    GoRoute(path: AppRoutes.letDriverKnow, builder: (_, _) => const LetDriverKnowScreen()),
    GoRoute(path: AppRoutes.notificationCentre, builder: (_, _) => const NotificationCentreScreen()),
    GoRoute(path: AppRoutes.adminDashboard, builder: (_, _) => const AdminDashboardScreen()),
    GoRoute(path: AppRoutes.adminVerification, builder: (_, _) => const AdminVerificationScreen()),
    GoRoute(path: AppRoutes.adminUsers, builder: (_, _) => const AdminUsersScreen()),
    GoRoute(path: AppRoutes.adminConfig, builder: (_, _) => const AdminConfigScreen()),
    GoRoute(path: AppRoutes.webLanding, builder: (_, _) => const WebLandingScreen()),
    GoRoute(path: AppRoutes.webSignIn, builder: (_, _) => WebSignInScreen()),
    GoRoute(path: AppRoutes.webDashboard, builder: (_, _) => const WebDashboardScreen()),
    GoRoute(path: AppRoutes.webFindRide, builder: (_, _) => WebFindRideScreen()),
    GoRoute(path: AppRoutes.webPostRide, builder: (_, _) => WebPostRideScreen()),
    GoRoute(path: AppRoutes.webMyRides, builder: (_, _) => const WebMyRidesScreen()),
    GoRoute(path: AppRoutes.webProfile, builder: (_, _) => WebProfileScreen()),
    GoRoute(path: AppRoutes.catalog, builder: (_, _) => const ScreenCatalogScreen()),
  ],
);
