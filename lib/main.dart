import 'package:flutter/material.dart';
import 'package:passwd/passwordpage.dart';
import 'colors.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Password manager",
      theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: dark, // Your accent color
          ),
          primaryColor: deeppurple,
      ),
      home: HomePage()
  ),
  );
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: dark,
          body: Center(
            child: Form(
              key:formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.lock_person,
                    color: lightpurple,
                    size: 75,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    child: TextFormField(
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20),
                      obscureText: true,
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: lightpurple,
                        labelText: "Введите мастер-пароль",
                        labelStyle: TextStyle(
                          color: dark
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5
                        )
                      ),
                      validator: (_val){
                        if (_val == "qwerty"){
                          _controller.clear();
                          return null;
                        }
                        else {
                          _controller.clear();
                          return "Некорректный мастер-пароль";
                        }
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if(formkey.currentState!.validate()) {
                        print("Провалидирован");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => PasswordPage()));
                      }
                    },
                    child: Text(
                      "Войти",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightpurple
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }
}
