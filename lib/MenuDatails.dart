import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Menudetails extends StatefulWidget {
  Menudetails({super.key});
  @override
  State<Menudetails> createState() => MenudetailsState();
}

class MenudetailsState extends State<Menudetails> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Details'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 200),
        child: Container(
          height: 230,
          color: Colors.black38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Contact Us',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),),
                   Text('Click on the icon to contact', style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
              
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: IconButton(
                  onPressed: () {
                    final Uri WhatsappUri =
                        Uri.parse('https://wa.me/+923349134820');
                    launchUrl(WhatsappUri,
                        mode: LaunchMode.externalApplication);
                  },
                  icon: Icon(Icons.chat),
                  color: Colors.white,
                ),
                title: Text('WhatsApp'),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                ),
                tileColor: Colors.black12,
              ),
              SizedBox(
                height: 10,
              ),
              ListTile(
                leading: IconButton(
                  onPressed: () {
                    final Uri EmailUri = Uri(scheme: 'mailto',path: 'shfqt22@gamil.com');
                    launchUrl(EmailUri,
                        mode: LaunchMode.externalApplication);
                  },
                  icon: Icon(Icons.email),
                  color: Colors.white,
                ),
                title: Text('Email'),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                ),
                tileColor: Colors.black12,
              )
            ],
          ),
        ),
      ),
    );
  }
}
