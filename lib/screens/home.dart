import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_fmen/main.dart';
import 'package:todo_fmen/widgets/add_todo.dart';
import 'package:http/http.dart' as http;

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
      body: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late List todos = [];

  void getTodos() async {
    String? jwt = await storage.read(key: "jwt");

    var serverResponse = await http.get(
      Uri.http(server, "api/v1/todos/get"),
      headers: <String, String> {
        'Content-Type': 'application/json',
        'Authorization': jwt as String
      }
    );

    var data = jsonDecode(serverResponse.body);
    setState(() {
      todos = data["todos"] as List;
    });
  }

  void deleteTodo(String id) async {
    String? jwt = await storage.read(key: "jwt");

    var serverResponse = await http.delete(
      Uri.http(server, "api/v1/todos/delete/$id"),
      headers: <String, String> {
        'Content-Type': 'application/json',
        'Authorization': jwt as String
      }
    );

    var data = jsonDecode(serverResponse.body);
  }
  
  @override
  Widget build(BuildContext context) {
    getTodos();
    
    return todos.isEmpty ? const Center(
      child: Text("Add your todo now!"),
    ) : ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 12, left: 12),
            child: Card(
              child: ListTile(
                title: Text(todos[index]["title"]),
                subtitle: Text(todos[index]["description"]),
                trailing: TextButton(
                  child: const Text(
                    "Delete",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () => {
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        title: Text("Delete the todo"),
                        content: Text("Are you sure to delete the todo"),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context),
                          ),
                          TextButton(
                            child: Text("Ok"),
                            onPressed: () {
                              deleteTodo(todos[index]["_id"]);
                              Navigator.pop(context);
                            },
                          )
                        ],
                      );
                    },)
                  }
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}