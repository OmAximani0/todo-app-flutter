import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo_fmen/screens/home.dart';
import 'package:todo_fmen/screens/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  runApp(const MyApp());
}

const storage = FlutterSecureStorage();

class MyApp extends StatelessWidget {

  Future<String> get jwtOrEmpty async {
    Future.delayed(const Duration(seconds: 8));
    var jwt = await storage.read(key: "jwt");
    if(jwt == null) return "";
    return jwt;
  }

  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: jwtOrEmpty,
        initialData: null,
        builder: (context, snapshot) {
          if(!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if(snapshot.data != "") {
            String str = snapshot.data as String;
            var jwt = str.split(".");
            if(jwt.length !=3) {
              return const LoginScreen();
            } else {
              var payload = json.decode(ascii.decode(base64.decode(base64.normalize(jwt[1]))));
              if(DateTime.fromMillisecondsSinceEpoch(payload["exp"]*1000).isAfter(DateTime.now())) {
                return HomeScreen(str, payload);
              } else {
                return const LoginScreen();
              }
            }
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
