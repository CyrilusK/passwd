import 'package:flutter/material.dart';
import 'package:passwd/passwordpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:passwd/pages/auth/login_page.dart';
import 'package:passwd/pages/auth/signup_page.dart';
import 'package:passwd/pages/list_mfa_page.dart';
import 'package:passwd/pages/mfa/verify_page.dart';
import 'package:passwd/pages/mfa/enroll_page.dart';

const supabaseUrl = '';
const supabaseKey = '';

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
}

// void main() async {
//   await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
//   runApp(
//     //MaterialApp(
//       // debugShowCheckedModeBanner: false,
//       // title: "Password manager",
//       // theme: ThemeData(
//       //     colorScheme: ColorScheme.fromSwatch().copyWith(
//       //       secondary: dark, // Your accent color
//       //     ),
//       //     primaryColor: deeppurple,
//       // ),
//       //home:
//       MyApp()
//  // ),
//   );
// }

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

// class HomePage extends StatefulWidget {
//   @override
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//
//   GlobalKey<FormState> formkey = GlobalKey<FormState>();
//   TextEditingController _controller = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//           backgroundColor: dark,
//           body: Center(
//             child: Form(
//               key:formkey,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   Icon(
//                     Icons.lock_person,
//                     color: lightpurple,
//                     size: 75,
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//                     child: TextFormField(
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20),
//                       obscureText: true,
//                       controller: _controller,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: lightpurple,
//                         labelText: "Введите мастер-пароль",
//                         labelStyle: TextStyle(
//                           color: dark
//                         ),
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 5
//                         )
//                       ),
//                       validator: (_val){
//                         if (_val == "qwerty"){
//                           _controller.clear();
//                           return null;
//                         }
//                         else {
//                           _controller.clear();
//                           return "Некорректный мастер-пароль";
//                         }
//                       },
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       if(formkey.currentState!.validate()) {
//                         print("Провалидирован");
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (context) => PasswordPage()));
//                       }
//                     },
//                     child: Text(
//                       "Войти",
//                       style: TextStyle(
//                         fontSize: 20,
//                         color: Colors.white,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: lightpurple
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//   }
// }
