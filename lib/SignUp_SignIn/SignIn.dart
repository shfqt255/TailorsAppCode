// ignore_for_file: body_might_complete_normally_nullable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tailors_application/Home.dart';
import 'package:tailors_application/SignUp_SignIn/UserAuthentication.dart';
import 'ForgotPasswordEmailEntry.dart';
import 'SignUp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  SignIn({super.key});
  @override
  State<SignIn> createState() => SignInState();
}

class SignInState extends State<SignIn> {
  FirebaseAuthentication authservice = FirebaseAuthentication();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final RegExp _emailRegex = RegExp(
    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
  );
  final RegExp _passwordRegex =
      RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$%&*?~]).{8,}$');
  bool _togglepassword = true;
  void _passwordvisiblility() {
    setState(() {
      _togglepassword = !_togglepassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 150, left: 20, right: 20),
        child: Column(
          children: [
            Text(
              'Log in to your Account',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1),
            Text(
              'Welcome back, please enter your details',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black45,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.lightBlue,
                            width: 1,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black45,
                          width: 0.5,
                        )),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.lightBlue,
                            width: 1,
                          ),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                        floatingLabelStyle: TextStyle(
                          color: Colors.lightBlue,
                        ),
                        suffixIcon:
                            Icon(Icons.email, size: 25, color: Colors.blueGrey),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '* Required feild';
                        } else if (!_emailRegex.hasMatch(value.trim())) {
                          return 'Please Enter a valid email';
                        }
                      },
                      cursorColor: Colors.lightBlue,
                      cursorErrorColor: Colors.lightBlue,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Colors.lightBlue,
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black45, width: 0.5)),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.lightBlue, width: 1),
                          ),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black45, width: 0.5)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.lightBlue, width: 1)),
                          suffixIcon: IconButton(
                            onPressed: _passwordvisiblility,
                            icon: Icon(
                              _togglepassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.blueGrey,
                              size: 25,
                            ),
                            color: Colors.blueGrey,
                            iconSize: 25,
                          )),
                      obscureText: _togglepassword,
                      //  obscuringCharacter: '*',
                      cursorColor: Colors.lightBlue,
                      cursorErrorColor: Colors.lightBlue,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '* Required field';
                        } else if (!_passwordRegex.hasMatch(value.trim())) {
                          return 'Enter at least 8 Characters(A,a,1,#)';
                        }
                      },
                    ),
                    SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ForgetpasswordFirstPage()),
                            );
                          },
                          child: Text(
                            'Forget Password?',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),
                    ElevatedButton(
                        onPressed: () async {
                          final form = _formKey.currentState;
                          if (form != null && form.validate()) {
                            Signin();
                            SharedPreferences preferences =
                                await SharedPreferences.getInstance();
                            preferences.setBool('isSignedUp', true);
                          } else {
                            print("Form is invalid");
                          }
                        },
                        child: Text(
                          'Login',
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ))),
                    SizedBox(height: 30),
                    Text(
                      '_________________Sign in with_________________',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black26,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15),
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
                        // const SizedBox(width: 20),
                        // IconButton(
                        //   icon: const Icon(Icons.facebook,
                        //       color: Colors.blue, size: 37),
                        //   onPressed: () {},
                        // ),
                        // const SizedBox(width: 20),
                        // IconButton(
                        //   icon: const Icon(Icons.apple, size: 37),
                        //   onPressed: () {},
                        // ),
                        // const SizedBox(width: 20),
                        // IconButton(
                        //   icon: Image.asset(
                        //     'lib/assets/images/x.png',
                        //     height: 28,
                        //     width: 32,
                        //   ),
                        //   onPressed: () {},
                        // ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't Have an account? ",
                          textAlign: TextAlign.center,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Signup()),
                            );
                          },
                          child: const Text(
                            "SignUp",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void Signin() async {
    String email = emailController.text;
    String password = passwordController.text;
    User? user = await authservice.SigninwithEmailandPassword(email, password);
    if (user != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
    } else {
      print('Not login');
    }
  }
}
