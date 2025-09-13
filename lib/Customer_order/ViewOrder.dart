import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderView extends StatefulWidget {
  String? OrderID;
  String? CustomerID;
  OrderView({super.key, this.CustomerID, this.OrderID});
  State<OrderView> createState() => OrderViewState();
}

class OrderViewState extends State<OrderView> {
  TableRow buildCustomerTableRow(IconData icon, String text, String title) {
    return TableRow(children: [
      SizedBox(
        height: 40,
        width: 10,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.blueGrey,
                size: 20,
              ),
              SizedBox(
                width: 5,
              ),
              Text(title),
            ],
          ),
        ),
      ),
      SizedBox(
        height: 40,
        width: 20,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text),
        ),
      )
    ]);
  }

  TableRow buildMeasurementsAndDetails(String title1, String data1) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title1,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            data1,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
        titleTextStyle: TextStyle(fontSize: 20),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Customer')
                    .doc(widget.CustomerID)
                    .snapshots(),
                builder: (context, CustomerSnapshot) {
                  if (CustomerSnapshot.hasError) {
                    Fluttertoast.showToast(msg: 'Some error Occured ');
                  }
                  if (CustomerSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!CustomerSnapshot.hasData ||
                      CustomerSnapshot.data == null) {
                    return Center(
                      child: Text('No Customer Found'),
                    );
                  }
                  final data =
                      CustomerSnapshot.data!.data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Details: ',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Table(border: TableBorder.all(), columnWidths: {
                          0: FixedColumnWidth(130),
                          1: FlexColumnWidth(),
                        }, children: [
                          buildCustomerTableRow(
                              Icons.person, data['Name'] ?? '', 'Name'),
                          buildCustomerTableRow(
                              Icons.phone, data['Phone'] ?? '', 'Phone'),
                          buildCustomerTableRow(Icons.location_on,
                              data['Address'] ?? '', 'Address')
                        ]),
                      ],
                    ),
                  );
                }),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Customer')
                    .doc(widget.CustomerID)
                    .collection('Measurements')
                    .snapshots(),
                builder: (context, Snapshot) {
                  if (Snapshot.hasError) {
                    Fluttertoast.showToast(msg: 'Some error Occured ');
                  }
                  if (Snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!Snapshot.hasData || Snapshot.data == null) {
                    return Center(
                      child: Text('No Customer Found'),
                    );
                  }
                  final Mdata = Snapshot.data!.docs;

                  return Column(
                    children: Mdata.map((doc) {
                      final Mapdata = doc.data() as Map<String, dynamic>;

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Measurements: ',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue),
                            ),
                            Table(
                              border: TableBorder.all(),
                              children: [
                                buildMeasurementsAndDetails(
                                  'Qameez Length',
                                  (Mapdata['qameezLength'] ?? '').toString(),
                                ),
                                buildMeasurementsAndDetails(
                                  'Arm Length',
                                  (Mapdata['ArmLength'] ?? '').toString(),
                                ),
                                buildMeasurementsAndDetails('Cuff/Round Sleeve',
                                    (Mapdata['CuffLength'] ?? '').toString()),
                                buildMeasurementsAndDetails('Cuff Width',
                                    (Mapdata['CuffWidth'] ?? '').toString()),
                                buildMeasurementsAndDetails('Shoulder Length',
                                    (Mapdata['ShoulderLength'] ?? '').toString()),
                                buildMeasurementsAndDetails('Neck/Collar',
                                    (Mapdata['Neck/CollarLength'] ?? '').toString()),
                                buildMeasurementsAndDetails('Chest Length',
                                    (Mapdata['ChestLength'] ?? '').toString()),
                                buildMeasurementsAndDetails('Waist Length',
                                    (Mapdata['WaistLength'] ?? '').toString()),
                                buildMeasurementsAndDetails('Hem/ Daman',
                                    (Mapdata['HemLength'] ?? '').toString()),
                                buildMeasurementsAndDetails('Shalwar Length',
                                    (Mapdata['ShalwarLength'] ?? '').toString()),
                                buildMeasurementsAndDetails('Pancha',
                                    (Mapdata['PanchaLength'] ?? '').toString()),
                                buildMeasurementsAndDetails('FronPocket',
                                    (Mapdata['FrontPocket'] ?? '').toString()),
                                buildMeasurementsAndDetails('Side Pockets',
                                    (Mapdata['Side Pockets'] ?? '').toString()),
                                buildMeasurementsAndDetails(
                                    'Galla', (Mapdata['GallaType'] ?? '').toString()),
                                buildMeasurementsAndDetails('Sleeve Type',
                                    (Mapdata['SleeveType'] ?? '').toString()),
                                buildMeasurementsAndDetails(
                                    'Hem Type', (Mapdata['HemType'] ?? '').toString()),
                                buildMeasurementsAndDetails(
                                    'Additional Information',
                                    (Mapdata['Additional Information'] ?? '')
                                        .toString()),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                }),
            // FIXED: Use doc() instead of snapshots() to get specific order
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Customer')
                  .doc(widget.CustomerID)
                  .collection('Orders')
                  .doc(widget.OrderID) // Get specific order by ID
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  Fluttertoast.showToast(msg: 'Some error Occured ');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                  return Center(
                    child: Text('No Order Found'),
                  );
                }
                final data = snapshot.data!.data() as Map<String, dynamic>;
                
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details: ',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlue),
                      ),
                      Table(
                        border: TableBorder.all(),
                        children: [
                          buildMeasurementsAndDetails('No.Suits', (data['NumberOfSuits'] ?? '').toString()),
                          buildMeasurementsAndDetails('Delivery Date', (data['DeliveryDate'] ?? '').toString()),
                          buildMeasurementsAndDetails('Urgent', (data['Urgent'] ?? '').toString()),
                          buildMeasurementsAndDetails('AmountPerSuit', (data['PerSuitAmount'] ?? '').toString()),
                          buildMeasurementsAndDetails('Total Amount', (data['Total Amount'] ?? '').toString()),
                          buildMeasurementsAndDetails('Advance Amount', (data['Advance Amount'] ?? '').toString()),
                          buildMeasurementsAndDetails('Remaining Amount', (data['Remaining Amount'] ?? '').toString()),
                        ],
                      )
                    ],
                  )
                );
              },
            )
          ],
        ),
      ),
    );
  }
}