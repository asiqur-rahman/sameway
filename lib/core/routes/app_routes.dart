abstract final class AppAssets {
  static const routeIllustration = 'assets/images/route_match.png';
  static const logoIcon = 'assets/images/logo_icon.png';
}

abstract final class AppRoutes {
  // Onboarding
  static const splash = '/';
  static const signUp = '/sign-up';
  static const profileSetup = '/profile-setup';
  static const vehicle = '/vehicle';
  static const workLocation = '/work-location';
  static const officeId = '/office-id';

  // Main tabs
  static const home = '/home';
  static const rides = '/rides';
  static const chat = '/chat';
  static const profile = '/profile';

  // Offer ride flow
  static const postRideEmpty = '/post-ride';
  static const pickStart = '/post-ride/pick-start';
  static const pickEnd = '/post-ride/pick-end';
  static const addStop = '/post-ride/add-stop';
  static const routeConfirmed = '/post-ride/confirmed';
  static const postRideFilled = '/post-ride/filled';
  static const incomingRequests = '/post-ride/requests';

  // Find ride flow
  static const searchFilters = '/find-ride/filters';
  static const searchResults = '/find-ride/results';
  static const rideDetail = '/find-ride/detail';

  // Match & communication
  static const requestSent = '/request-sent';
  static const chatConversation = '/chat/conversation';
  static const myProfile = '/my-profile';
  static const regularRoutes = '/regular-routes';

  // Ride day
  static const reminderSettings = '/reminders';
  static const departureIn = '/ride-day/departure';
  static const afterHeadingOut = '/ride-day/heading-out';
  static const pickupIn = '/ride-day/pickup';
  static const letDriverKnow = '/ride-day/let-driver-know';
  static const notificationCentre = '/notifications';

  // Admin
  static const adminDashboard = '/admin';
  static const adminVerification = '/admin/verification';
  static const adminUsers = '/admin/users';
  static const adminConfig = '/admin/config';

  // Web
  static const webLanding = '/web';
  static const webSignIn = '/web/sign-in';
  static const webDashboard = '/web/dashboard';
  static const webFindRide = '/web/find-ride';
  static const webPostRide = '/web/post-ride';
  static const webMyRides = '/web/my-rides';
  static const webProfile = '/web/profile';

  static const catalog = '/catalog';
}
