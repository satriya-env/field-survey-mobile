// import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/login.dart';
import 'app_routes.dart';

class AppPages{
  static final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes:[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, route) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, route) => const Login(),
      ),
    ],
  );
}