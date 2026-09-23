// import 'package:flutter/material.dart';
import 'package:azhmobile/screens/auth/register.dart';
import 'package:azhmobile/screens/dashboard/home.dart';
import 'package:azhmobile/screens/dashboard/page/editprofile.dart';
// import 'package:azhmobile/screens/dashboard/page/profiledit.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login.dart';
import 'app_routes.dart';

class AppPages {
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, route) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, route) => const Login(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, route) => const Register(),
      ),
      GoRoute(path: AppRoutes.home, builder: (context, route) => const Home()),
      GoRoute(
        path: AppRoutes.edit,
        builder: (context, route) => const EditProfile(),
      ),
    ],
  );
}
