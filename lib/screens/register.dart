import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo_fmen/screens/login.dart';
import 'package:todo_fmen/utils/text_decorations.dart';
import 'package:todo_fmen/utils/validators/text_input_validation.dart';
import 'package:http/http.dart' as http;

const String serverIP = "fmen-todo-backend.herokuapp.com";

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({ Key? key }) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with ValidationMixin {

  final _formKey = GlobalKey<FormState>();

  // Form value holders
  String name = "";
  String email = "";
  String password = "";

  bool isSubmitting = false;

  final Shader registerColor = const LinearGradient(
    colors: <Color>[Color(0xff5FAE86), Color(0xff468D97)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {

    void registerUser(String nameValue, String emailValue, String passwordValue) async {
      var jsonData = jsonEncode({
        "email": emailValue,
        "name": nameValue,
        "password": passwordValue
      });

      var serverResponse = await http.post(
        Uri.http(serverIP, "api/v1/users/register"),
        body: jsonData,
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        }
      );

      final responseData = json.decode(serverResponse.body);

      setState(() => isSubmitting = false);

      if(responseData['status'] == 1) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[400],
            content:const Text(
              "Registered Succesfully!",
              style: TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          )
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[400],
            content: Text(
              responseData['error'],
              style: const TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          )
        );
      }
    }

    void submit() {
      setState(() => isSubmitting = true);
      if(_formKey.currentState!.validate() == true) {
        _formKey.currentState!.reset(); // Reset the form
        registerUser(name, email, password);
      } else {
        setState(() => isSubmitting = false);
      }
    }

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.png'),
          fit: BoxFit.cover
        ),
      ),
      child: isSubmitting ? Center(
        child: CircularProgressIndicator(
          value: null,
          strokeWidth: 7.0,
          backgroundColor: Colors.blue[300],
        ),
      ) : Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Positioned(
                top: 220,
                left: 50,
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 38,
                    foreground: Paint()..shader = registerColor,
                  ),
                ),
              ),
              Positioned(
                top: 275,
                left: 52,
                child: SizedBox(
                  width: 280,
                  child: TextFormField(
                    keyboardType: TextInputType.name,
                    decoration: landingFields.copyWith(
                      hintText: 'Name',
                    ),
                    validator: (value) {
                      if(isNameValid(value!)) {
                        name = value;
                        return null;
                      } else {
                        return "Name must be 2 character long";
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                top: 365,
                left: 52,
                child: SizedBox(
                  width: 280,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: landingFields.copyWith(hintText: 'Email Id'),
                    validator:(value) {
                      if(isEmailValid(value!)) {
                        email = value;
                        return null;
                      }
                      else {
                        return "Invalid Email id";
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                top: 455,
                left: 52,
                child: SizedBox(
                  width: 280,
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    decoration: landingFields.copyWith(hintText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if(isPasswordValid(value!)) {
                        password = value;
                        return null;
                      }
                      else {
                        return "Password length should be 8";
                      }
                    }
                  ),
                ),
              ),
              Positioned(
                top: 548,
                left: 120,
                width: 140,
                height: 50,
                child: TextButton(
                  onPressed: () => submit(),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1DBBFF),
                  ),
                ),
              ),
              Positioned(
                top: 615,
                right: 70,
                child: GestureDetector(
                  onTap: () => {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder:(context) => const LoginScreen(),
                    ))
                  },
                  child: Text(
                    "Already have an account? Login here",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}
