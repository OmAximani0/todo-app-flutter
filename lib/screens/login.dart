import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_fmen/screens/home.dart';
import 'package:todo_fmen/screens/register.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_fmen/utils/text_decorations.dart';
import 'package:todo_fmen/utils/validators/text_input_validation.dart';

const String server = "fmen-todo-backend.herokuapp.com";
const storage = FlutterSecureStorage();

class LoginScreen extends StatefulWidget {
  const LoginScreen({ Key? key }) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with ValidationMixin{

  final _formKey = GlobalKey<FormState>();

  // Form value holders
  String email = "";
  String password = "";

  bool isSubmitting = false;

  final Shader loginColor = const LinearGradient(
    colors: <Color>[Color(0xff5FAE86), Color(0xff468D97)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {

    void loginUser(String emailValue, String passwordValue) async {
      var jsonData = jsonEncode({
        "email": emailValue,
        "password": passwordValue
      });

      var serverResponse = await http.post(
        Uri.http(server, "api/v1/users/login"),
        body: jsonData,
        headers: <String, String> {
          'Content-Type': 'application/json; charset=UTF-8',
        }
      );

      final responseData = json.decode(serverResponse.body);
      storage.write(key: "jwt", value: responseData['token']);

      setState(() {
        isSubmitting = false;
      });
      if(responseData['status'] == 1) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => HomeScreen(responseData["token"], responseData),
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[400],
            content:const Text(
              "Logged In Succesfully!",
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
      setState(() {
        isSubmitting = true;

      });
      if(_formKey.currentState!.validate() == true) {
        _formKey.currentState!.reset(); // Reset the form
        loginUser(email, password);
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
                top: 228,
                left: 50,
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 38,
                    foreground: Paint()..shader = loginColor,
                  ),
                ),
              ),
              Positioned(
                top: 320,
                left: 52,
                child: SizedBox(
                  width: 280,
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: landingFields.copyWith(hintText: 'Email Id'),
                    validator: (inputEmailValue) {
                      if(isEmailValid(inputEmailValue!)) {
                        email = inputEmailValue;
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
                top: 405,
                left: 52,
                child: SizedBox(
                  width: 280,
                  child: TextFormField(
                    keyboardType: TextInputType.visiblePassword,
                    decoration: landingFields.copyWith(hintText: 'Password'),
                    obscureText: true,
                    validator: (inputPasswordValue) {
                      if(isPasswordValid(inputPasswordValue!)) {
                        password = inputPasswordValue;
                        return null;
                      }
                      else {
                        return "Password length should be 8";
                      }
                    },
                  ),
                ),
              ),
              Positioned(
                top: 510,
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
                top: 590,
                right: 70,
                child: GestureDetector(
                  onTap: () => {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => const RegisterScreen()
                    ))
                  },
                  child: Text(
                    "Don't have an account? Register here",
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
