import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:passwd/main.dart';
import 'package:passwd/pages/auth/signup.dart';
import 'package:passwd/passwordpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MFAEnrollPage extends StatefulWidget {
  static const route = '/mfa/enroll';
  const MFAEnrollPage({super.key});

  @override
  State<MFAEnrollPage> createState() => _MFAEnrollPageState();
}

class _MFAEnrollPageState extends State<MFAEnrollPage> {
  final _enrollFuture = supabase.auth.mfa.enroll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Установка TOTP'),
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
      body: FutureBuilder(
        future: _enrollFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final response = snapshot.data!;
          final qrCodeUrl = response.totp.qrCode;
          final secret = response.totp.secret;
          final factorId = response.id;

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            children: [
              const Text(
                'Откройте приложение-аутентификатор и добавьте это приложение с помощью QR-кода или вставки кода ниже',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SvgPicture.string(
                qrCodeUrl,
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      secret,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: secret));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Скопировано в буфер обмена')));
                    },
                    icon: const Icon(Icons.copy),
                  ),
                ],
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
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Непредвиденная ошибка')));
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
