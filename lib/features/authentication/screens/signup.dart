import 'package:elderly_prototype_app/features/authentication/screens/login.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/start_screen.dart';
import 'package:elderly_prototype_app/features/authentication/data/auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  // Define the primary color based on the user's request
  final Color _primaryColor = const Color(0xFF48352A);
  final Color _textFieldBackground = const Color(0xFFedf0f8);
  final Color _hintTextColor = const Color(0xFFb2b7bf);

  String email = "", password = "", name = "";
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController mailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    if (_formkey.currentState!.validate()) {
      setState(() {
        email = mailcontroller.text;
        name = namecontroller.text;
        password = passwordcontroller.text;
      });

      try {
        // Validation check is already done by the FormState,
        // but we keep the additional check on email/name text for safety before calling Firebase
        if (name.isNotEmpty && email.isNotEmpty) {
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(email: email, password: password);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
            "Registered Successfully",
            style: TextStyle(fontSize: 20.0),
          )));
          // ignore: use_build_context_synchronously
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const StartScreen()));
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              )));
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
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
                'Create Account',
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
                    // --- Name Field ---
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
                            return 'Please Enter Name';
                          }
                          return null;
                        },
                        controller: namecontroller,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Name",
                            hintStyle: TextStyle(
                                color: _hintTextColor, fontSize: 16.0)),
                      ),
                    ),

                    const SizedBox(height: 20.0),

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
                            return 'Please Enter Email';
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter Password';
                          }
                          return null;
                        },
                        controller: passwordcontroller,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(
                                color: _hintTextColor, fontSize: 16.0)),
                      ),
                    ),

                    const SizedBox(height: 40.0),

                    // --- Sign Up Button (using Primary Color) ---
                    GestureDetector(
                      onTap: registration,
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
                            "Sign Up",
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
              "or Sign up with",
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
                Image.asset(
                  // Note: Ensure your assets path is correct
                  "assets/images/apple1.png",
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                )
              ],
            ),

            const SizedBox(height: 40.0),

            // --- Don't have an account / Login link ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?",
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 5.0),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Login()));
                  },
                  child: Text(
                    "Login",
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
