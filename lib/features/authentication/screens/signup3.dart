import 'package:elderly_prototype_app/features/authentication/screens/login3.dart';
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
  // Define the colors based on the user's request (Brown/Darker Palette)
  final Color _primaryColor = const Color(0xFF48352A); // Dark Brown
  final Color _secondaryColor =
      const Color(0xFF8D6E63); // Medium Brown (for accents/circles)
  final Color _backgroundColor =
      const Color(0xFFF5F5F5); // Light Gray/Off-white background
  final Color _textFieldBackground = Colors.white; // White for text fields
  final Color _hintTextColor = Colors.black54;

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
        if (name.isNotEmpty && email.isNotEmpty) {
          await FirebaseAuth.instance
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

  // --- Widget for the decorative circles in the background ---
  Widget _buildTopCircles(BuildContext context) {
    return Positioned(
      top: -100,
      left: -100,
      child: Stack(
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: _secondaryColor.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: 50,
            left: 50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget for the bottom decorative circles ---
  Widget _buildBottomCircles(BuildContext context) {
    return Positioned(
      bottom: -150,
      right: -150,
      child: Stack(
        children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: _secondaryColor.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Text Input Field Widget with Icon and modern style ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
          color: _textFieldBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ]),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please Enter $hintText';
          }
          return null;
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _hintTextColor.withOpacity(0.7)),
          border: InputBorder.none,
          hintText: hintText,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintStyle: TextStyle(color: _hintTextColor, fontSize: 16.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Background decorative elements
          _buildTopCircles(context),
          _buildBottomCircles(context),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.black, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Content of the signup screen
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  // Space for the top circles
                  const SizedBox(height: 250.0),

                  // --- Login / Register Toggle ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to Login (Current screen is SignUp)
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()));
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: _hintTextColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      Text(
                        'Register',
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: _primaryColor,
                          decorationThickness: 2.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40.0),

                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        // --- Name Field ---
                        _buildTextField(
                          controller: namecontroller,
                          hintText: "User Name",
                          icon: Icons.person_outline,
                        ),

                        // --- Email Field ---
                        _buildTextField(
                          controller: mailcontroller,
                          hintText: "Email",
                          icon: Icons.mail_outline,
                        ),

                        // --- Password Field ---
                        _buildTextField(
                          controller: passwordcontroller,
                          hintText: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),

                        const SizedBox(height: 40.0),

                        // --- Sign Up Button ---
                        GestureDetector(
                          onTap: registration,
                          child: Container(
                              width: MediaQuery.of(context).size.width * 0.5,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15.0),
                              decoration: BoxDecoration(
                                  color: _primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _primaryColor.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]),
                              child: const Center(
                                  child: Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ))),
                        ),
                      ],
                    ),
                  ),

                  // Social login section removed to match the requested design aesthetic.
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
                  const SizedBox(height: 150.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
