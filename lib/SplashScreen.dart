import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tailors_application/SignUp_SignIn/SignUp.dart';
import 'Home.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}
class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      bool isSignedUp = preferences.getBool('isSignedUp') ?? false;
      if(isSignedUp==true){
             Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Home()),
      );
      } else if(isSignedUp==false){
                Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Signup()),
      );
      }
   
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Container(),
            Container(
              height: 230,
              width: 290,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('lib/assets/images/splash4.jfif'),
                  fit: BoxFit.contain,
                ),
                border: Border.all(
                  color: Colors.transparent, // Border color
                  width: 5, // Border width
                ),
              ),
            ),
            SizedBox(height: 20),
            const Text(
              'Welcome to Tailors App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Effortless management for your Tailoring business',
              style: TextStyle(fontSize: 12),
            ),
            /*     IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Signup()),
                  );
                },
                icon: Image.asset(
                  'lib/assets/images/FirstPageButton.jpg', // Use your image path
                  width: 32,
                  height: 32,
                ),
              ),
              SizedBox(height: 0),
              Text(
                ' Move On',
                style: TextStyle(fontSize: 8),
              ),*/
          ],
        ),
      ),
    );
  }
}
