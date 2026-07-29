import 'package:elderly_prototype_app/core/app_theme.dart';
import 'package:elderly_prototype_app/features/authentication/screens/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = "";
  TextEditingController mailcontroller = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  Future<void> resetPassword() async {
    try {
      // NOTE: an earlier version of this method tried to detect
      // Google-only accounts first via fetchSignInMethodsForEmail(), but
      // that method has been removed from current versions of the
      // firebase_auth package (yours is ^6.1.1) — it doesn't compile
      // against it. There isn't a reliable client-side replacement, since
      // newer Firebase projects intentionally don't expose this
      // information (to prevent email enumeration). Sending a reset email
      // to a Google-only account isn't harmful, though: Firebase treats it
      // as adding a password as an additional sign-in method for that
      // account, rather than an error, so this still leaves the user with
      // a working path forward instead of a dead end.
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;
      // FIX: wording no longer confirms an account exists (a small but
      // deliberate security practice — matches how Firebase's own hosted
      // UI phrases this), while still being clear about what to do next.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          "If an account exists for this email, a password reset link "
          "has been sent.",
          style: TextStyle(fontSize: 18.0),
        ),
      ));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code == "user-not-found") {
        // Kept for Firebase projects without enumeration protection,
        // where this error can still be thrown directly.
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
          "No user found for that email.",
          style: TextStyle(fontSize: 20.0),
        )));
      } else {
        // FIX: previously any other error was silently swallowed with no
        // feedback at all (e.g. "invalid-email", "too-many-requests").
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Something went wrong: ${e.message ?? e.code}",
            style: const TextStyle(fontSize: 18.0),
          ),
        ));
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
              height: 70.0,
            ),
            Container(
              alignment: Alignment.topCenter,
              child: Text(
                "Password Recovery",
                style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              "Enter your mail",
              style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold),
            ),
            Expanded(
                child: Form(
                    key: _formkey,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: ListView(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppTheme.primaryColor, width: 2.0),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please Enter Email';
                                }
                                return null;
                              },
                              controller: mailcontroller,
                              style: TextStyle(color: AppTheme.primaryColor),
                              decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                      fontSize: 18.0,
                                      color: AppTheme.primaryColor),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: AppTheme.primaryColor,
                                    size: 30.0,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                          SizedBox(
                            height: 40.0,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = mailcontroller.text;
                                });
                                resetPassword();
                              }
                            },
                            child: Container(
                              width: 140,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  "Send Email",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                    fontSize: 18.0,
                                    color: AppTheme.primaryColor),
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignUp()));
                                },
                                child: Text(
                                  "Create",
                                  style: TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
}
