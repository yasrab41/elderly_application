import 'package:elderly_prototype_app/features/authentication/screens/forgot_password.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/start_screen.dart';
import 'package:elderly_prototype_app/features/authentication/data/auth_methods.dart';
import 'package:elderly_prototype_app/features/authentication/screens/signup3.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Define the new color scheme based on the image
  // final Color _primaryColor = const Color(0xFF1E88E5); // Bright Blue
  // final Color _secondaryColor = const Color(0xFF42A5F5); // Lighter Blue
  // final Color _backgroundColor =
  //     const Color(0xFFE3F2FD); // Very Light Blue/Off-white

  final Color _primaryColor = const Color(0xFF48352A); // Dark Brown
  final Color _secondaryColor =
      const Color(0xFF8D6E63); // Medium Brown (for accents/circles)
  final Color _backgroundColor = const Color.fromARGB(
      255, 255, 255, 255); // Light Gray/Off-white background

  final Color _textFieldBackground = Colors.white; // White for text fields
  final Color _hintTextColor = Colors.black54;

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
        // Navigate to StartScreen on successful login
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StartScreen()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                "No User Found for that Email",
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              )));
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                "Wrong Password Provided by User",
                style: TextStyle(fontSize: 18.0, color: Colors.white),
              )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Error: ${e.message}",
                style: const TextStyle(fontSize: 18.0, color: Colors.white),
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

          // Content of the login screen
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  // Space for the top circles
                  const SizedBox(height: 250.0),

                  // --- Login / Register Toggle (New UI Style) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: _primaryColor,
                          decorationThickness: 2.0,
                        ),
                      ),
                      const SizedBox(width: 20.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()));
                        },
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: _hintTextColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40.0),

                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        // --- Email Field (Now Username/Email) ---
                        _buildTextField(
                          controller: mailcontroller,
                          hintText:
                              "Username", // Changed from Email to match image
                          icon: Icons.person_outline,
                        ),

                        // --- Password Field ---
                        _buildTextField(
                          controller: passwordcontroller,
                          hintText: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                        ),

                        // --- Forgot Password (Moved to below fields for cleaner look) ---
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
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 5.0, bottom: 20.0),
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: _hintTextColor,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // --- Login Button ---
                        GestureDetector(
                          onTap: userLogin,
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
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold),
                              ))),
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
                        const SizedBox(height: 150.0),
                      ],
                    ),
                  ),

                  // The social login and sign up link have been removed
                  // as they are not present in the reference image for this simplified UI.
                  const SizedBox(height: 50.0),

                  // Empty space to push content up if needed and account for bottom circles
                  const SizedBox(height: 150.0),
                ],
              ),
            ),
          ),

          // Re-adding the back button from the original design
          Positioned(
            top: 50,
            left: 20,
            child: SafeArea(
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          )
        ],
      ),
    );
  }
}
