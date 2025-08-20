// ignore_for_file: body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailors_application/Home.dart';
import 'package:tailors_application/SignUp_SignIn/EmailVerification.dart';
import 'SignIn.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'UserAuthentication.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  FirebaseAuthentication authservice = FirebaseAuthentication();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void dispose() {
    businessNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final RegExp pass_valid =
      RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%&\*?\~]).{8,}$');
  final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  bool _obsecurePassword = true;
  bool _obsecureConfirmPassword = true;
  void toggleEye() {
    setState(() {
      _obsecurePassword = !_obsecurePassword;
    });
  }

  void toggleEyeConfirm() {
    setState(() {
      _obsecureConfirmPassword = !_obsecureConfirmPassword;
    });
  }

  String passwordValue = '';
  String ConfirmPasswordValue = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 100.0, right: 20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Create Your Account",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      "Sign Up now to get started with an accout",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: businessNameController,
                decoration: InputDecoration(
                    labelText: 'Business Name', //Label Text
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                    floatingLabelStyle: TextStyle(color: Colors.lightBlue),
                    suffixIcon:
                        Icon(Icons.person, color: Colors.blueGrey, size: 25),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45, width: 0.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue, width: 1),
                    )),
                cursorColor: Colors.lightBlue,
                cursorErrorColor: Colors.lightBlue,
                validator: (Value) {
                  if (Value == null || Value.trim().isEmpty) {
                    return '* Required field';
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email ', //Label Text
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                    floatingLabelStyle: TextStyle(color: Colors.lightBlue),
                    suffixIcon:
                        Icon(Icons.email, color: Colors.blueGrey, size: 25),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45, width: 0.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue, width: 1),
                    )),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '* Required field';
                  } else if (!_emailRegex.hasMatch(value.trim())) {
                    return 'Please Enter a valid email';
                  }
                },
                cursorColor: Colors.lightBlue, //CursorColor
                cursorErrorColor: Colors.lightBlue,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: passwordController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '* Required field';
                  } else if (!pass_valid.hasMatch(value.trim())) {
                    return 'Enter at least 8 characters(A,a,1,#)';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    passwordValue = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  floatingLabelStyle: const TextStyle(color: Colors.lightBlue),
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 0.5),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue, width: 1),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obsecurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.blueGrey,
                      size: 25,
                    ),
                    onPressed: toggleEye,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45, width: 0.5),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue, width: 1),
                  ),
                ),
                obscureText: _obsecurePassword, // Secure text input
                keyboardType:
                    TextInputType.visiblePassword, // Password keyboard
                cursorColor: Colors.lightBlue,
                cursorErrorColor: Colors.lightBlue,
                // Cursor color
              ),
              const SizedBox(height: 15),
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '* Required field';
                  } else if (value.trim() != passwordValue.trim()) {
                    return 'Enter same password';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    ConfirmPasswordValue = value;
                  });
                },
                obscureText: _obsecureConfirmPassword,
                decoration: InputDecoration(
                    labelText: 'Confirm Password', //LabeledText
                    floatingLabelStyle: TextStyle(color: Colors.lightBlue),
                    labelStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obsecureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blueGrey,
                        size: 25,
                      ),
                      onPressed: toggleEyeConfirm,
                    ),
                    enabledBorder: OutlineInputBorder(
                      //Enable Border
                      borderSide: BorderSide(color: Colors.black45, width: 0.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      //Focus Border
                      borderSide: BorderSide(color: Colors.lightBlue, width: 1),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45, width: 0.5),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue, width: 1),
                    )),
                keyboardType: TextInputType.visiblePassword, //KeyboardType
                cursorColor: Colors.lightBlue, // cursor color
                cursorErrorColor: Colors.lightBlue,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
  final form = _formKey.currentState;
  if (form != null && form.validate()) {
    try {
      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      //  First sign up the user
      User? user = await authservice.SignupwithEmailandPassword(email, password);

      if (user != null) {
        //  Then save BusinessName with the new user's UID
        await FirebaseFirestore.instance
            .collection('businesses')
            .doc(user.uid)
            .set({
          "BusinessName": businessNameController.text.trim(),
          "Email": email,
        });

        //  Move to email verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerifyEmailPage()),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'SignUp failed: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
},

                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue, // 👈 Fill color
                  foregroundColor: Colors.white, // 👈 Text color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(5), // 👈 Rounded corners
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "_____________Or sign up with______________",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black26,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset(
                      'lib/assets/images/G.png',
                      height: 32,
                      width: 32,
                    ),
                    onPressed: () async {
                      final UserCard = await authservice.signInWithGoogle();
                      if (UserCard != null) {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('isSignedUp', true);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => Home()));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignIn()),
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

//   void SignUp() async {
//     // String businessName = businessNameController.text;
//     String email = emailController.text;
//     String password = passwordController.text;
//     User? user = await authservice.SignupwithEmailandPassword(email, password);
//     if (user != null) {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => VerifyEmailPage()));
//     } else {
//       print("some errors occurs");
//     }
//   }
}
