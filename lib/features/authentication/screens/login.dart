// ignore_for_file: use_build_context_synchronously

import 'package:elderly_prototype_app/features/authentication/screens/forgot_password.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/start_screen.dart';
import 'package:elderly_prototype_app/features/authentication/data/auth_methods.dart';
import 'package:elderly_prototype_app/features/authentication/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// You need a file at this path for Google sign-in
// import 'package:elderly_prototype_app/features/authentication/data/auth_methods.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Color Palette
  final Color _primaryColor = const Color(0xFF48352A);
  final Color _textFieldBackground = const Color(0xFFedf0f8);
  final Color _hintTextColor = const Color(0xFFb2b7bf);

  // Controllers and Key
  TextEditingController mailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  // Regex for basic email format validation
  static final RegExp _emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  // 🚀 FIX: Function to handle Login logic
  userLogin() async {
    // 1. Validate the form first
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!
          .save(); // Ensure 'onSaved' is called if you were using it

      // Update state for clear variable usage (optional but clean)
      String email = mailcontroller.text.trim();
      String password = passwordcontroller.text.trim();

      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // Success: Navigate to the home screen
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const StartScreen()));
      } on FirebaseAuthException catch (e) {
        String errorMessage;

        if (e.code == 'user-not-found') {
          errorMessage = "No user found for that email.";
        } else if (e.code == 'wrong-password') {
          errorMessage = "Incorrect password. Please try again.";
        } else if (e.code == 'invalid-email') {
          // This covers the 'badly formatted email' error from the logs
          errorMessage = "The email address is badly formatted.";
        } else {
          errorMessage = "Login failed. Check your credentials and try again.";
        }

        // Show the error message to the user
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              errorMessage,
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            )));
      } catch (e) {
        // Handle general exceptions (e.g., network issues)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "An unexpected error occurred: ${e.toString()}",
              style: const TextStyle(fontSize: 16.0, color: Colors.white),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        controller: mailcontroller,
                        keyboardType: TextInputType.emailAddress, // Better UX
                        // 🚀 FIX: Explicit Email Validation
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your E-mail';
                          }
                          if (!_emailRegExp.hasMatch(value.trim())) {
                            return 'Enter a valid email address'; // Fixes the logged error
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                            // 🚀 FIX: Removed all borders for clean look
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,

                            // Added padding to prevent content/hint from touching box top/bottom
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                            isDense: true,
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
                            return 'Please enter your Password';
                          }
                          return null;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                            // 🚀 FIX: Removed all borders for clean look
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15.0),
                            isDense: true,
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
                      // 🚀 FIX: Calling the login function
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
                    // Assuming AuthMethods().signInWithGoogle is correctly defined
                    AuthMethods().signInWithGoogle(context);
                  },
                  child: Image.asset(
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
