import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:passwd/main.dart';
import 'package:passwd/pages/auth/signup.dart';
import 'package:passwd/passwordpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MFAVerifyPage extends StatefulWidget {
  static const route = '/mfa/verify';
  const MFAVerifyPage({super.key});

  @override
  State<MFAVerifyPage> createState() => _MFAVerifyPageState();
}

class _MFAVerifyPageState extends State<MFAVerifyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Верификация'),
        actions: [
          TextButton(
            onPressed: () {
              supabase.auth.signOut();
              context.go(RegisterPage.route);
            },
            child: Text(
              'Выйти',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 24,
        ),
        children: [
          Text(
            'Требуется проверка',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          const Text('Введите код, указанный в приложении-аутентификаторе'),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              hintText: '000000',
            ),
            style: const TextStyle(fontSize: 24),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) async {
              if (value.length != 6) return;

              // kick off the verification process once 6 characters are entered
              try {
                final factorsResponse = await supabase.auth.mfa.listFactors();
                final factor = factorsResponse.totp.first;
                final factorId = factor.id;

                final challenge =
                await supabase.auth.mfa.challenge(factorId: factorId);
                await supabase.auth.mfa.verify(
                  factorId: factorId,
                  challengeId: challenge.id,
                  code: value,
                );
                await supabase.auth.refreshSession();
                if (mounted) {
                  context.go(PasswordPage.route);
                }
              } on AuthException catch (error) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(error.message)));
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Непредвиденная ошибка')));
              }
            },
          ),
        ],
      ),
    );
  }
}
