// ignore_for_file: file_names, prefer_const_constructors_in_immutables, annotate_overrides, non_constant_identifier_names, non_constant_identifier_names, duplicate_ignore, body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:tailors_application/SignUp_SignIn/SignIn.dart';
import 'package:tailors_application/SignUp_SignIn/UserAuthentication.dart';


class ForgetpasswordFirstPage extends StatefulWidget {
  ForgetpasswordFirstPage({super.key});
  @override
  State<ForgetpasswordFirstPage> createState() =>
      ForgetpasswordFirstPageState();
}

class ForgetpasswordFirstPageState extends State<ForgetpasswordFirstPage> {
  FirebaseAuthentication firebaseAuthentication = FirebaseAuthentication();
  final _formKey = GlobalKey<FormState>();
  final RegExp _emailRegex = RegExp(
    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
  );
  TextEditingController EmailController = TextEditingController();
  @override
  void dispose() {
    EmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 250, left: 20, right: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Text(
                        'Forgot Password',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Enter the Email that is associated with your account to receive the link for reseting  your password',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10,),
                       Text(
                        'Note: The New Password must be at least 8 characters, 1 number, 1 Capital letter, 1 small letter, and 1 special letter. Otherwise You will be not allowed to login',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: EmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                          floatingLabelStyle:
                              TextStyle(color: Colors.lightBlue),
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
                          )),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black45, width: 0.5)),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.lightBlue, width: 1),
                          ),
                        ),
                        cursorColor: Colors.lightBlue,
                        cursorErrorColor: Colors.lightBlue,
                        //  cursorHeight: 20,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '* required field';
                          } else if (!_emailRegex.hasMatch(value.trim())) {
                            return '* Enter a valid Email';
                          }
                        },
                      ),
                      SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () async {
                          final form = _formKey.currentState;
                          if (form != null && form.validate()) {
                            firebaseAuthentication.ResetPassword(
                                EmailController.text.trim());
                          } else {
                            print("Form is invalid");
                          }
                        },
                        child: Text('Submit'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.lightBlue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            )),
                      ),
                      SizedBox(height: 15,),
                      ElevatedButton(onPressed: (){
    Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignIn()));
                      }, child:  Text('Return to login'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.lightBlue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            )), )
                    ],
                  )))
        ]),
      ),
    );
  }
}
