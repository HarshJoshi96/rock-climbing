import 'package:go_router/go_router.dart';
import 'package:namer_app/src/data/models/activity_data.dart';
import 'package:namer_app/src/presentation/activity_details_screen.dart';
import 'package:namer_app/src/presentation/booking_screen.dart';
import 'package:namer_app/src/presentation/home_screen.dart';
import 'package:namer_app/src/presentation/landing_screen.dart';
import 'package:namer_app/src/presentation/login_screen.dart';
import 'package:namer_app/src/presentation/otp_screen.dart';
import 'package:namer_app/src/presentation/payment_screen.dart';
import 'package:namer_app/src/presentation/payment_successful_screen.dart';
import 'package:namer_app/src/presentation/phone_screen.dart';
import 'package:namer_app/src/presentation/profile_screen.dart';
import 'package:namer_app/src/presentation/signature_screen.dart';
import 'package:namer_app/src/presentation/signup_screen.dart';

class RoutePaths {
  static const String home = '/';
  static const String signature = '/signatureScreen';
  static const String activityDetails = '/activityDetailsScreen';
  static const String bookingScreen = '/bookingScreen';
  static const String landingScreen = '/landingScreen';
  static const String signupScreen = '/signupScreen';
  static const String loginScreen = '/loginScreen';
  static const String paymentScreen = '/paymentScreen';
  static const String profileScreen = '/profileScreen';
  static const String otpScreen = '/otpScreen';
  static const String paymentSuccessScreen = '/paymentSuccessScreen';
  static const String phoneScreen = '/phoneScreen';
}

final routes = GoRouter(
  routes: [
    GoRoute(
        path: RoutePaths.landingScreen,
        builder: (context, state) => LandingScreen()),
    GoRoute(
        path: RoutePaths.signature,
        builder: (context, state) =>
            SignatureScreen(testString: state.extra as String)),
    GoRoute(
        path: RoutePaths.activityDetails,
        builder: (context, state) =>
            ActivityDetailsScreen(activityData: state.extra as ActivityData)),
    GoRoute(
        path: RoutePaths.bookingScreen,
        builder: (context, state) => BookingStepsScreen(
              activityData: state.extra as ActivityData,
            )),
    GoRoute(
        path: RoutePaths.signupScreen,
        builder: (context, state) => SignupScreen()),
    GoRoute(
        path: RoutePaths.loginScreen,
        builder: (context, state) => LoginScreen()),
    GoRoute(
        path: RoutePaths.paymentScreen,
        builder: (context, state) => PaymentScreen()),
    GoRoute(
      path: RoutePaths.home,
      builder: (context, state) => Home(),
    ),
    GoRoute(
        path: RoutePaths.profileScreen,
        builder: (context, state) => ProfileScreen()),
    GoRoute(
      path: RoutePaths.otpScreen,
      builder: (context, state) {
        final bool isNewUser = state.extra as bool? ?? false;
        return OTPScreen(navigateToHome: isNewUser);
      },
    ),
    GoRoute(
        path: RoutePaths.paymentSuccessScreen,
        builder: (context, state) => PaymentSuccessScreen()),
    GoRoute(
        path: RoutePaths.phoneScreen,
        builder: (context, state) => PhoneAuthScreen()),
    GoRoute(
      path: '/auth/callback',
      builder: (context, state) {
        final deepLink = state.uri.toString();
        print("Deep Link: $deepLink");
        return OTPScreen(navigateToHome: true);
      },
    ),
  ],
  redirect: (context, state) {
    if (state.uri.toString().contains("auth/callback")) {
      return '/auth/callback';
    }
    return null;
  },
);
