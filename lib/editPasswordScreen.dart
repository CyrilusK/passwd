import 'package:flutter/material.dart';
import 'package:passwd/generatorPass.dart';
import 'colors.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'dart:convert';

class EditPasswordScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EditPasswordScreen({Key? key, required this.data}) : super(key: key);

  @override
  _EditPasswordScreenState createState() => _EditPasswordScreenState();
}

class _EditPasswordScreenState extends State<EditPasswordScreen> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  bool obscureText = true;
  late TextEditingController _serviceController;
  late TextEditingController _loginController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _serviceController =
        TextEditingController(text: widget.data['service_name']);
    _loginController = TextEditingController(text: widget.data['login']);
    _passwordController = TextEditingController(text: widget.data['password']);
  }

  @override
  void dispose() {
    _serviceController.dispose();
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? validateempty(_val) {
    if (_val.isEmpty) {
      return "Необходимо заполнить поле";
    } else {
      return null;
    }
  }

  Future<bool> isPasswordCompromised(String password) async {
    if (password.isEmpty) throw Exception('You must provide a password');

    final digest = sha1.convert(utf8.encode(password)).toString().toUpperCase();
    final firstFive = digest.substring(0, 5);

    final response = await http.get(Uri.parse('https://api.pwnedpasswords.com/range/$firstFive'));

    if (response.statusCode == 200) {
      final body = response.body;
      return body.split('\r\n').any((o) => firstFive + o.split(':')[0] == digest);
    } else {
      throw Exception('Failed to check password: ${response.reasonPhrase}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      appBar: AppBar(
        title: Text(
          'Редактирование данных',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(
          color: Colors.white, // Установка белого цвета иконки "назад"
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
        child: Form(
          key: formstate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextFormField(
                controller: _serviceController,
                decoration: InputDecoration(
                  labelText: 'Веб-сайт',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: validateempty,
                onChanged: (_val) {
                  _serviceController.text = _val;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _loginController,
                decoration: InputDecoration(
                  labelText: 'Логин/Email/номер',
                  labelStyle: TextStyle(color: Colors.white),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
                validator: validateempty,
                onChanged: (_val) {
                  _loginController.text = _val;
                },
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: obscureText,
                      decoration: InputDecoration(
                        labelText: 'Пароль',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureText = !obscureText;
                                });
                              },
                              icon: Icon(obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              color: Colors.white,
                            ),
                            IconButton(
                              onPressed: () {
                                String newPass = generatePassword(
                                    _serviceController.text,
                                    _passwordController.text);
                                _passwordController.text = newPass;
                                print('[DEBUG] - Пароль успешно сгенерирован');
                              },
                              icon: Icon(Icons.refresh),
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      validator: validateempty,
                      onChanged: (_val) {
                        _passwordController.text = _val;
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_passwordController.text.isNotEmpty) {
                          bool compromised = await isPasswordCompromised(_passwordController.text);
                          if (compromised) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text("Пароль был найден в базе данных утечек. Пожалуйста, выберите другой пароль")));
                          }
                          else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text("Пароль не найден в базе данных утечек")));
                          }
                        }
                      },
                      child: Text('Проверить'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (formstate.currentState!.validate()) {
                          final editedData = {
                            'id': widget.data['id'],
                            'service_name': _serviceController.text,
                            'login': _loginController.text,
                            'password': _passwordController.text,
                          };
                          Navigator.of(context).pop(editedData);
                        }
                      },
                      child: Text('Сохранить'),
                    ),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
