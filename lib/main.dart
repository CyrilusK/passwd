import 'package:flutter/material.dart';
import 'package:passwd/passwordpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:passwd/pages/auth/login_page.dart';
import 'package:passwd/pages/auth/signup_page.dart';
import 'package:passwd/pages/list_mfa_page.dart';
import 'package:passwd/pages/mfa/verify_page.dart';
import 'package:passwd/pages/mfa/enroll_page.dart';

const supabaseUrl = 'https://jbpgjnxurqhijasmvige.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpicGdqbnh1cnFoaWphc212aWdlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTA5NDQwMDcsImV4cCI6MjAyNjUyMDAwN30.x8mnaNQ9k6UuIBUERNsTHoT9q0v2KZ6GfCJ-Gp-qGmc';

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

final _router = GoRouter(
  routes: [
    GoRoute(
      path: PasswordPage.route,
      builder: (context, state) => const PasswordPage(),
    ),
    GoRoute(
      path: ListMFAPage.route,
      builder: (context, state) => ListMFAPage(),
    ),
    GoRoute(
      path: LoginPage.route,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RegisterPage.route,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: MFAEnrollPage.route,
      builder: (context, state) => const MFAEnrollPage(),
    ),
    GoRoute(
      path: MFAVerifyPage.route,
      builder: (context, state) => const MFAVerifyPage(),
    ),
  ],
  redirect: (context, state) async {
    // Any users can visit the /auth route
    if (state.uri.toString().contains('/auth') == true) {
      return null;
    }

    final session = supabase.auth.currentSession;
    // A user without a session should be redirected to the register page
    if (session == null) {
      return LoginPage.route;
    }

    final assuranceLevelData =
    supabase.auth.mfa.getAuthenticatorAssuranceLevel();

    // The user has not setup MFA yet, so send them to enroll MFA page.
    if (assuranceLevelData.currentLevel == AuthenticatorAssuranceLevels.aal1) {
      await supabase.auth.refreshSession();
      final nextLevel =
          supabase.auth.mfa.getAuthenticatorAssuranceLevel().nextLevel;
      if (nextLevel == AuthenticatorAssuranceLevels.aal2) {
        // The user has already setup MFA, but haven't login via MFA
        // Redirect them to the verify page
        return MFAVerifyPage.route;
      } else {
        // The user has not yet setup MFA
        // Redirect them to the enrollment page
        return MFAEnrollPage.route;
      }
    }

    // The user has signed invia MFA, and is allowed to view any page.
    return null;
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Password manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      routerConfig: _router,
    );
  }
}



