import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passwd/pages/auth/login_page.dart';
import 'colors.dart';
import 'package:go_router/go_router.dart';
import 'package:passwd/main.dart';
import 'package:passwd/pages/list_mfa_page.dart';
import 'supabasehelper.dart';
import 'dart:async';
import 'package:passwd/generatorPass.dart';
import 'package:passwd/editPasswordScreen.dart';

class PasswordPage extends StatefulWidget {
  static const route = '/';

  const PasswordPage({super.key});
  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  bool obscureText = true;
  Timer? _timer;
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  final sphelper = SupabaseHelper.instance;
  String? type;
  String? login;
  String? pass;
  List<Map<String, dynamic>> allrows = [];

  TextStyle titlestyle = TextStyle(
    fontSize: 20.0,
    color: Colors.white,
  );

  TextStyle subtitlestyle = TextStyle(
    fontSize: 16.0,
    color: Colors.white,
  );

  String? validateempty(_val) {
    if (_val.isEmpty) {
      return "Необходимо заполнить поле";
    } else {
      return null;
    }
  }

  Future<String> encrypt(String text, String key) async {
    try {
      final encryptedData = await platform.invokeMethod('encrypt', {'text': text, 'key': key});
      return encryptedData;
    } on PlatformException catch (e) {
      print("[DEBUG] - Failed to encrypt: '${e.message}'");
      return '';
    }
  }

  Future<String> decrypt(String data, String key) async {
    try {
      final decryptedData = await platform.invokeMethod('decrypt', {'data': data, 'key': key});
      return decryptedData;
    } on PlatformException catch (e) {
      print("[DEBUG] - Failed to decrypt: '${e.message}'");
      return '';
    }
  }

  void insertdata() async {
    Navigator.pop(context);
    //final encrypedPass = await encrypt(pass!, login!);
    final id = await sphelper.addUserAccount(type!, login!, pass!);
    setState(() {});
  }

  Future<void> queryall() async {
    try {
      allrows = await sphelper.getUserAccounts();
      print('[DEBUG] - Получены данные из базы данных: $allrows');
    } catch (error) {
      print('[DEBUG] - Ошибка при получении данных из базы данных: $error');
    }
  }

  void addPassword() {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              backgroundColor: Colors.indigo,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              title: Text(
                "Добавить данные",
                style: subtitlestyle,
                textAlign: TextAlign.center,
              ),
              children: <Widget>[
                Form(
                  key: formstate,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Веб-сайт",
                          labelStyle: subtitlestyle,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                        style: titlestyle,
                        validator: validateempty,
                        onChanged: (_val) {
                          type = _val;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Логин/е-мейл/номер",
                          labelStyle: subtitlestyle,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                        style: titlestyle,
                        validator: validateempty,
                        onChanged: (_val) {
                          login = _val;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Пароль",
                          labelStyle: subtitlestyle,
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                        style: titlestyle,
                        validator: validateempty,
                        onChanged: (_val) {
                          pass = _val;
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (formstate.currentState!.validate()) {
                              print("[DEBUG] - Ready To Enter Data");
                              insertdata();
                            }
                          },
                          child: Text("Добавить", style: titlestyle),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }

  void editPassword(Map<String, dynamic> data, int index) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPasswordScreen(data: data),
      ),
    ).then((value) {
      // Выполняется после закрытия экрана редактирования
      if (value != null && value is Map<String, dynamic>) {
        List<Map<String, dynamic>> updatedList = List.from(allrows);
        updatedList[index] = value;
        // Обновляем данные после редактирования
        setState(() {
          allrows = updatedList;
          sphelper.updateUserAccount(
              value['id'],
              value['service_name'],
              value['login'],
              value['password']);
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: deeppurple,
        centerTitle: true,
        title: Text("Сохраненные данные", style: titlestyle),
        actions: [
          PopupMenuButton(
            iconColor: Colors.white,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: const Text('Отменить МФА'),
                  onTap: () {
                    context.push(ListMFAPage.route);
                  },
                ),
                PopupMenuItem(
                  child: const Text('Выйти'),
                  onTap: () {
                    supabase.auth.signOut();
                    allrows = [];
                    context.go(LoginPage.route);
                  },
                ),
              ];
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPassword,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      backgroundColor: dark,
      body: FutureBuilder(
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasData != null) {
            if (allrows.isEmpty) {
              return Center(
                child: Text(
                  "Отсутствуют данные",
                  style: titlestyle,
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return Center(
                child: Container(
                  decoration: BoxDecoration(),
                  width: MediaQuery.of(context).size.width * 0.95,
                  child: ListView.builder(
                    itemCount: allrows.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: UniqueKey(),
                        background: Container(
                          color: Colors.blue, // Цвет фона для удаления
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.edit, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red, // Цвет фона для редактирования
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Icon(Icons.delete, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            // Обработка удаления
                            final deletedItem = allrows.removeAt(index);
                            setState(() {
                            });
                            if (allrows.isEmpty) {
                              setState(() {
                                Center(
                                  child: Text(
                                    "Отсутствуют данные",
                                    style: titlestyle,
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              });
                            }
                            // Вызов метода для удаления элемента из базы данных
                            sphelper.deleteUserAccount(deletedItem['id']);
                          } else if (direction == DismissDirection.startToEnd) {
                            // Обработка редактирования
                            print('[DEBUG] - ${allrows.elementAt(index)}');
                            final tipe = allrows.elementAt(index);
                            editPassword(allrows.elementAt(index), index);
                            setState(() {
                            });
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            top: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: deeppurple,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(allrows[index]['service_name'],
                                    textAlign: TextAlign.center,
                                    style: titlestyle),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.account_circle,
                                  size: 40.0,
                                  color: Colors.white,
                                ),
                                title: Text(
                                  allrows[index]['login'],
                                  style: titlestyle,
                                ),
                                subtitle: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        enabled: false,
                                        initialValue: allrows[index]
                                            ['password'],
                                        style: titlestyle,
                                        obscureText: obscureText,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder
                                              .none, // Установка пустой границы
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            obscureText = !obscureText;
                                          });
                                        },
                                        icon: Icon(obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility),
                                        color: Colors.white),
                                    IconButton(
                                      onPressed: () async {
                                        await Clipboard.setData(ClipboardData(
                                            text: allrows[index]['password']));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                              "Пароль скопирован в буфер обмена"),
                                        ));
                                        _timer =
                                            Timer(Duration(seconds: 20), () {
                                          Clipboard.setData(
                                              ClipboardData(text: ''));
                                          _timer?.cancel();
                                        });
                                      },
                                      icon: Icon(Icons.content_copy),
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        future: queryall(),
      ),
    );
  }
}
