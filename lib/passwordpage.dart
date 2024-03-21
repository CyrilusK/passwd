import 'package:flutter/material.dart';
import 'colors.dart';
import 'dbhelper.dart';
import 'package:go_router/go_router.dart';
import 'package:passwd/main.dart';
import 'package:passwd/pages/auth/signup.dart';
import 'package:passwd/pages/list_mfa_page.dart';

class PasswordPage extends StatefulWidget {
  static const route = '/';

  const PasswordPage({super.key});
  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  GlobalKey<FormState> formstate = GlobalKey<FormState>();
  final dbhelper = Databasehelper.instance;
  String? type;
  String? user;
  String? pass;
  var allrows = [];

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

  void insertdata() async {
    Navigator.pop(context);
    Map<String, dynamic> row = {
      Databasehelper.columnType: type,
      Databasehelper.columnUser: user,
      Databasehelper.columnPass: pass,
    };
    final id = await dbhelper.insert(row);
    print(id);
    setState(() {});
  }

  Future<void> queryall() async {
    allrows = await dbhelper.queryall();
  }

  void addpassword() {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          backgroundColor: Colors.indigo,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 15.0,
          ),
          title: Text("Добавить данные", style: subtitlestyle, textAlign: TextAlign.center,),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 5),
                    child: TextFormField(
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
                        user = _val;
                      },
                    ),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Пароль",  labelStyle: subtitlestyle,
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
                          print("Ready To Enter Data");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Сохраненные данные",
          style: titlestyle
        ),
          actions: [
          PopupMenuButton(
          itemBuilder: (context) {
          return [
            PopupMenuItem(child: const Text('Отменить МФА'), onTap: () {
              context.push(ListMFAPage.route);
              },
            ),
            PopupMenuItem(child: const Text('Выйти'), onTap: () {
              supabase.auth.signOut();
              context.go(RegisterPage.route);
              },
            ),
          ];
          },
          )
          ],
        backgroundColor: Colors.indigo,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addpassword,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      backgroundColor: dark,
      body: FutureBuilder(
        builder: (context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasData != null) {
            if (allrows.length == 0) {
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
                      return Container(
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
                                  child: Text(
                                    allrows[index]['type'],
                                    textAlign: TextAlign.center,
                                    style: titlestyle
                                  ),
                                ),
                            ListTile(
                              leading: Icon(
                                Icons.facebook,
                                size: 40.0,
                                color: Colors.white,
                              ),
                              title: Text(
                                allrows[index]['user'],
                                style: titlestyle,
                              ),
                              subtitle: Text(
                                allrows[index]['pass'],
                                style: subtitlestyle,
                              ),
                            ),
                          ],
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