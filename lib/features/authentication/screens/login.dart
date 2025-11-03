// ignore_for_file: use_build_context_synchronously

import 'package:elderly_prototype_app/features/authentication/screens/forgot_password.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/start_screen.dart';
import 'package:elderly_prototype_app/features/authentication/data/auth_methods.dart';
import 'package:elderly_prototype_app/features/authentication/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Define the primary color based on the user's request
  final Color _primaryColor = const Color(0xFF48352A);
  final Color _textFieldBackground = const Color(0xFFedf0f8);
  final Color _hintTextColor = const Color(0xFFb2b7bf);

  String email = "", password = "";

  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  userLogin() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        email = mailcontroller.text;
        password = passwordcontroller.text;
      });

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StartScreen()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "No User Found for that Email",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Wrong Password Provided by User",
                style: TextStyle(fontSize: 18.0),
              )));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap content in SingleChildScrollView to prevent overflow
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- NEW STYLISH HEADER ---
            Container(
              width: MediaQuery.of(context).size.width,
              height: 200,
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                ),
              ),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 30, bottom: 20),
              child: const Text(
                'Log In',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 40.0),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    // --- Email Field ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                          color: _textFieldBackground,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ]),
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
                                color: _hintTextColor, fontSize: 16.0)),
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // --- Password Field ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                          color: _textFieldBackground,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ]),
                      child: TextFormField(
                        controller: passwordcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(
                                color: _hintTextColor, fontSize: 16.0)),
                      ),
                    ),

                    const SizedBox(height: 15.0),

                    // --- Forgot Password ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPassword()));
                        },
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // --- Sign In Button (using Primary Color) ---
                    GestureDetector(
                      onTap: userLogin,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          decoration: BoxDecoration(
                              color: _primaryColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: _primaryColor.withOpacity(0.4),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]),
                          child: const Center(
                              child: Text(
                            "Sign In",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold),
                          ))),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30.0),

            // --- Or Login With Text ---
            Text(
              "or Login with",
              style: TextStyle(
                  color: _primaryColor,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 20.0),

            // --- Social Login Icons ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    AuthMethods().signInWithGoogle(context);
                  },
                  child: Image.asset(
                    // Note: Ensure your assets path is correct
                    "assets/images/google.png",
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 30.0),
                GestureDetector(
                  onTap: () {
                    // AuthMethods().signInWithApple();
                  },
                  child: Image.asset(
                    // Note: Ensure your assets path is correct
                    "assets/images/apple1.png",
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),

            const SizedBox(height: 40.0),

            // --- Don't have an account / SignUp link ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUp()));
                  },
                  child: Text(
                    "SignUp",
                    style: TextStyle(
                        color: _primaryColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
