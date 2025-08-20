// Home.dart
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tailors_application/Customer_order/AddNewCustomer.dart';
import 'package:tailors_application/Customer_order/Order.dart';
import 'package:tailors_application/Customer_order/ViewCustomers.dart';
import 'package:tailors_application/FinancialRecord.dart';
import 'package:tailors_application/SignUp_SignIn/SignIn.dart';
import 'package:tailors_application/ToDoList.dart';
import 'package:tailors_application/Worker/WorkersFetch.dart';
import 'MenuDatails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> {
  bool isDarkTheme = false;
  String? businessName;

  @override
  void initState() {
    super.initState();
    LoadBusinessName();
  }

Future<void> LoadBusinessName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('businesses')
      .doc(user.uid)
      .get();

  if (doc.exists) {
    setState(() {
      businessName = doc["BusinessName"] ?? "Tailors App";
    });
  } else {
    setState(() {
      businessName = "Tailors App";
    });
  }
}

  // Sign out helper
  Future<void> _signOut(BuildContext context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setBool('isSignedUp', false);
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    Fluttertoast.showToast(msg: 'Signed out');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignIn()));
  }

  // Delete account helper
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Fluttertoast.showToast(msg: 'No user signed in');
        return;
      }
      await user.delete();
      Fluttertoast.showToast(msg: 'Account deleted');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignIn()));
    } on FirebaseAuthException catch (e) {
      // Common case: requires recent login
      Fluttertoast.showToast(
        msg:
            'Failed to delete account. You may need to sign in again and try (recent login required). $e',
      );
    }
    // catch (e) {
    //   Fluttertoast.showToast(msg: 'Error deleting account.');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Left menu
      drawer: _buildDrawer(context),
      // Right settings drawer
      endDrawer: _buildSettingsDrawer(context),
      body: Column(
        children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
            ),
            child: Container(
              height: MediaQuery.of(context).padding.top,
              color: const Color.fromARGB(255, 1, 26, 46),
            ),
          ),
          Container(
            height: kToolbarHeight,
            color: Colors.lightBlue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Tooltip(
                    message: 'Menu',
                    child: Builder(
                      builder: (context) => IconButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          icon: Icon(Icons.menu, color: Colors.white)),
                    )),
                Text(
                  businessName ?? 'Tailors App',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                Tooltip(
                  message: 'sync',
                  child: IconButton(
                    onPressed: ()  {
                        LoadBusinessName();
                      Fluttertoast.showToast(
                        msg: "Reloaded",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.blueGrey,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    },
                    icon: Icon(Icons.sync, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          Expanded(
              child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Viewcustomers()));
                },
                child: Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlue, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/images/user.png',
                        width: 140,
                        height: 50,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Customer',
                        style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // --- Add Order Button ---
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => OrderPage()));
                  print('Order pressed');
                },
                child: Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlue, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 50,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset(
                            'lib/assets/images/order.png',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Order',
                        style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              // --- Workers Button ---
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => FetchWorkers()));
                  print('Workers pressed');
                },
                child: Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.lightBlue, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('lib/assets/images/workers.png',
                          width: 100, height: 50),
                      const Text(
                        'Workers',
                        style: TextStyle(fontSize: 16, color: Colors.lightBlue),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Financialrecord()));
                  },
                  child: Container(
                    height: 60,
                    width: 330,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Image.asset(
                            'lib/assets/images/saving.png',
                            height: 40,
                            width: 40,
                            color: Colors.lightBlue,
                          ),
                        ),
                        Text(
                          '      Financial Record',
                          style:
                              TextStyle(fontSize: 16, color: Colors.lightBlue),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  )),
              SizedBox(
                width: double.infinity,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ToDoList()));
                },
                child: Container(
                  height: 60,
                  width: 330,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.lightBlue, width: 1.5),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Image.asset('lib/assets/images/task.png',
                            color: Colors.lightBlue, height: 40, width: 40),
                      ),
                      Text(
                        '      To-Do-List',
                        style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
        ],
      ),
      bottomSheet: bottomSheet(context, isDarkTheme),
    );
  }

  // Bottom bar: use Builder so openEndDrawer works
  Widget bottomSheet(BuildContext context, bool isDark) {
    return Container(
      height: kToolbarHeight,
      color: Colors.lightBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: 'Home',
            child: IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Home()));
              },
              icon: Icon(Icons.home),
              color: Colors.white,
              iconSize: 35,
            ),
          ),
          Tooltip(
              message: ('Add new Customer'),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddNewCustomer()));
                },
                icon: Icon(Icons.person_add),
                iconSize: 35,
                color: Colors.white,
              )),
          Tooltip(
            message: 'Add new order',
            child: IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OrderPage()));
              },
              icon: Icon(Icons.list_alt),
              iconSize: 35,
              color: Colors.white,
            ),
          ),
          Tooltip(
            message: 'Settings',
            child: Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  // Open right side drawer (settings)
                  Scaffold.of(context).openEndDrawer();
                },
                icon: Icon(Icons.settings),
                iconSize: 35,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Left Menu Drawer (smaller header)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.only(top: 50),
      children: [
        // Reduced header height
        Container(
          height: 80,
          color: Colors.lightBlue,
          alignment: Alignment.center,
          child: const Text(
            'Menu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.contact_mail,
            size: 30,
            color: Colors.lightBlue,
          ),
          title: Text('Contact Us',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue)),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Menudetails()));
          },
        ),
        ListTile(
          leading: Icon(
            Icons.star,
            size: 30,
            color: Colors.amber,
          ),
          title: Text('Rate Us',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue)),
          onTap: () {
            Navigator.pop(context);
            Fluttertoast.showToast(msg: 'Coming Soon');
          },
        )
      ],
    ));
  }

  // Right Settings Drawer
  Widget _buildSettingsDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.only(top: 50),
        children: [
          // reduced settings header
          Container(
            height: 80,
            color: Colors.lightBlue,
            alignment: Alignment.center,
            child: const Text(
              'Settings',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: Text(
              'Sign Out',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue),
            ),
            leading: const Icon(
              Icons.logout,
              color: Colors.lightBlue,
              size: 30,
            ),
            onTap: () async {
              Navigator.pop(context); // close drawer
              await _signOut(context);
            },
          ),

          ListTile(
            title: Text(
              'Delete',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            leading: const Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 30,
            ),
            onTap: () async {
              Navigator.pop(context); // close drawer
              _confirmAndDelete(context);
            },
          ),
        ],
      ),
    );
  }

  // Ask for final confirmation before deleting account
  void _confirmAndDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure? This will permanently delete your account.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _deleteAccount(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
