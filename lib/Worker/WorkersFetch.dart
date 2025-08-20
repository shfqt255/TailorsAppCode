import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tailors_application/Worker/Workers.dart';
import 'package:tailors_application/Worker/WorkersPayments.dart';

class FetchWorkers extends StatefulWidget {
  const FetchWorkers({super.key});

  @override
  State<FetchWorkers> createState() => FetchWorkersState();
}

class FetchWorkersState extends State<FetchWorkers> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workers List'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('workers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Fluttertoast.showToast(msg: 'Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final workers = snapshot.data?.docs;
          return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, Index) {
                final WorkersData =
                    workers?[Index].data() as Map<String, dynamic>;
                return Card(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 16, bottom: 5, left: 16, right: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            WorkersData['name'],
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold),
                          ),
                          Text('Phone: ${WorkersData['phone']}'),
                            Text('CNIC:  ${WorkersData['cnic']}'),

                          Text(
                              'AmountPerSuit:  ${WorkersData['AmountPerSuit']}'),
                          Text(
                              'Remaining Amount:  ${WorkersData['RemainingAmount']}'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WorkersPayments(
                                                  workerId: snapshot
                                                      .data!.docs[Index].id,
                                                )));
                                  },
                                  child: Text(
                                    'Payments',
                                    style: TextStyle(
                                        color: Colors.lightBlue,
                                        fontWeight: FontWeight.bold),
                                  )),
                              // TextButton(
                              //     onPressed: () {},
                              //     child: Text(
                              //       'Edit',
                              //       style: TextStyle(
                              //           color: Colors.lightBlue,
                              //           fontWeight: FontWeight.bold),
                              //     )),
                              TextButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Delete Worker'),
                                            content: Text('All the data belongs to ${WorkersData['name']}'),
                                            
                                            actions: [ Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.lightBlue),
                                                    )),
                                                TextButton(
                                                    onPressed: () async {
                                                      FirebaseFirestore.instance
                                                          .collection('workers')
                                                          .doc(snapshot.data!
                                                              .docs[Index].id)
                                                          .delete();
                                                      Fluttertoast.showToast(
                                                          msg: 'Deleted',
                                                          backgroundColor:
                                                              Colors.black45,
                                                          textColor:
                                                              Colors.white,
                                                          gravity: ToastGravity
                                                              .BOTTOM);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )),
                                              ],
                                            ),]
                                          );
                                        });
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ))
                            ],
                          ),
                        ]),
                  ),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Workers()),
          );
        },
        label: Text('Add Worker'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
      ),
    );
  }
}
