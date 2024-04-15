import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passwd/main.dart';
import 'package:passwd/pages/mfa/enroll_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  static const route = '/auth/register';

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              label: Text('Электронная почта'),
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
                setState(() {
                  _isLoading = true;
                });
                final email = _emailController.text.trim();
                final password = _passwordController.text.trim();
                await supabase.auth.signUp(
                  email: email,
                  password: password,
                  //emailRedirectTo:
                  //    'passwd://callback${MFAEnrollPage.route}', // redirect the user to setup MFA page after email confirmation
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Успешно зарегистрировано')));
                  context.go(MFAEnrollPage.route);
                }
              } on AuthException catch (error) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error.message)));
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Непредвиденная ошибка')));
              }
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  )
                : const Text('Зарегистрироваться'),
          ),
        ],
      ),
    );
  }
}
