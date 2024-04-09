import 'package:flutter/material.dart';
import 'package:passwd/generatorPass.dart';
import 'colors.dart';

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
                child: ElevatedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
