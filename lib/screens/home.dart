import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_fmen/main.dart';
import 'package:todo_fmen/utils/text_decorations.dart';


const String server = "fmen-todo-backend.herokuapp.com";
const storage = FlutterSecureStorage();

class HomeScreen extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const HomeScreen(this.jwt, this.payload);

  final String jwt;
  final Map<String, dynamic> payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('My ToDo'),
        toolbarHeight: 70,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xff07ACCE),
                Color(0xff66CBC7)
              ]
            ),
          ),   
        ),
        actions: [
          TextButton(
            onPressed: () {
              storage.delete(key: "jwt");
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => const MyApp(),
              ));
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FittedBox(
          child: FloatingActionButton(
            child: const Icon(
              Icons.post_add_rounded,
              size: 30,
            ),
            elevation: 10,
            backgroundColor: const Color(0xff37BBCA),
            onPressed: () => {
              showModalBottomSheet(context: context, builder: (context) {
                return const AddTodoSheet();
              },)
            },
          ),
        ),
      ),
    );
  }
}

class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({
    Key? key,
  }) : super(key: key);

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {

  final _formKey = GlobalKey<FormState>();

  String todo = "";
  String desc = "";
  
  @override
  Widget build(BuildContext context) {

    void addTodo(String todoValue, String descValue) async {
      var jsonData = jsonEncode({
        "title": todoValue,
        "description": descValue
      });

      print(jsonData);

      String? jwt = await storage.read(key: "jwt");

      var serverResponse = await http.post(
        Uri.http(server, "api/v1/todos/add"),
        body: jsonData,
        headers: <String, String> {
          'Content-Type': 'application/json',
          'Authorization': jwt as String
        }
      );
    }

    void submit() {
      if(_formKey.currentState!.validate()== true) {
        _formKey.currentState!.reset();
        addTodo(todo, desc);
      }
    }

    return Container(
      color: Colors.grey[200],
      height: 500,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical:32.0, horizontal: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "Add Your Todo Here",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16
                    ),
                  ),
                ),
                TextFormField(
                  decoration: landingFields.copyWith(
                    hintText: "Add your todo",
                  ),
                  validator: (inTodoValue) {
                    if(inTodoValue!.isEmpty) {
                      return "Todo is required";
                    } else {
                      todo = inTodoValue;
                      return null;
                    }
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14.0),
                  child: TextFormField(
                    decoration: landingFields.copyWith(
                      hintText: "Todo description",
                    ),
                    validator: (inDescValue) {
                      if(inDescValue!.isEmpty) {
                        return "Description is required";
                      } else {
                        desc = inDescValue;
                        return null;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: ElevatedButton(
                    child: const Text("Add Todo"),
                    onPressed: () => submit(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
