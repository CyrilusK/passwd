import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passwd/main.dart';
import 'package:passwd/pages/auth/signup_page.dart';
import 'package:passwd/pages/mfa/verify_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:passwd/encryption.dart';

class LoginPage extends StatefulWidget {
  static const route = '/auth/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              label: Text('Емейл'),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              label: Text('Пароль'),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              try {
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();
                await supabase.auth.signInWithPassword(
                  email: email,
                  password: password,
                );
                if (mounted) {
                  final encryption = Encryption(password);
                  context.go(MFAVerifyPage.route);
                  print('[DEBUG] - user from login_page: ${supabase.auth.currentUser!.id}');
                }
              } on AuthException catch (error) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error.message)));
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Непредвиденная ошибка')));
              }
            },
            child: const Text('Войти'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push(RegisterPage.route),
            child: const Text('Зарегистрироваться'),
          )
        ],
      ),
    );
  }
}
