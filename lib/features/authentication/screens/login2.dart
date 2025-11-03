// ignore_for_file: use_build_context_synchronously

import 'package:elderly_prototype_app/features/authentication/screens/forgot_password.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/start_screen.dart';
import 'package:elderly_prototype_app/features/authentication/data/auth_methods.dart';
import 'package:elderly_prototype_app/features/authentication/screens/signup2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "";

  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StartScreen()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "No User Found for that Email",
              style: TextStyle(fontSize: 18.0),
            )));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(
              "Wrong Password Provided by User",
              style: TextStyle(fontSize: 18.0),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "assets/images/car.png",
                  fit: BoxFit.cover,
                )),
            SizedBox(
              height: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                          color: Color(0xFFedf0f8),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter E-mail';
                          }
                          return null;
                        },
                        controller: mailcontroller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(
                                color: Color(0xFFb2b7bf), fontSize: 18.0)),
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                      decoration: BoxDecoration(
                          color: Color(0xFFedf0f8),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextFormField(
                        controller: passwordcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(
                                color: Color(0xFFb2b7bf), fontSize: 18.0)),
                        obscureText: true,
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            email = mailcontroller.text;
                            password = passwordcontroller.text;
                          });
                        }
                        userLogin();
                      },
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(
                              vertical: 13.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                              color: Color(0xFF273671),
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(
                              child: Text(
                            "Sign In",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22.0,
                                fontWeight: FontWeight.w500),
                          ))),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ForgotPassword()));
              },
              child: Text("Forgot Password?",
                  style: TextStyle(
                      color: Color(0xFF8c8e98),
                      fontSize: 18.0,
                      fontWeight: FontWeight.w500)),
            ),
            SizedBox(
              height: 25.0,
            ),
            Text(
              "or Login with",
              style: TextStyle(
                  color: Color(0xFF273671),
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    AuthMethods().signInWithGoogle(context);
                  },
                  child: Image.asset(
                    "assets/images/google.png",
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 30.0,
                ),
                GestureDetector(
                  onTap: () {
                    // AuthMethods().signInWithApple();
                  },
                  child: Image.asset(
                    "assets/images/apple1.png",
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 40.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?",
                    style: TextStyle(
                        color: Color(0xFF8c8e98),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500)),
                SizedBox(
                  width: 5.0,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUp()));
                  },
                  child: Text(
                    "SignUp",
                    style: TextStyle(
                        color: Color(0xFF273671),
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
