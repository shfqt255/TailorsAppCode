import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tailors_application/Customer_order/Order.dart';
import 'AddNewCustomer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Viewcustomers extends StatefulWidget {
  Viewcustomers({super.key});

  @override
  State<Viewcustomers> createState() => _ViewcustomersState();
}

class _ViewcustomersState extends State<Viewcustomers> {
  final CollectionReference customerRef =
      FirebaseFirestore.instance.collection('Customer');
  
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by name or phone',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white, fontSize: 18),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                cursorColor: Colors.white,
              )
            : Text("Customer List"),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  searchController.clear();
                  searchQuery = '';
                } else {
                  isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: customerRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            Fluttertoast.showToast(
              msg: "Error: ${snapshot.error}",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final customers = snapshot.data!.docs;

          if (customers.isEmpty) {
            return Center(child: Text("No customers found"));
          }
          
          // Filter customers based on search query
          final filteredCustomers = customers.where((customer) {
            if (searchQuery.isEmpty) return true;
            
            final name = customer['Name'].toString().toLowerCase();
            final phone = customer['Phone'].toString().toLowerCase();
            
            return name.contains(searchQuery) || phone.contains(searchQuery);
          }).toList();

          filteredCustomers.sort((a, b) => a['Name']
              .toString()
              .toLowerCase()
              .compareTo(b['Name'].toString().toLowerCase()));

          if (filteredCustomers.isEmpty) {
            return Center(child: Text("No customers found matching '$searchQuery'"));
          }

          return ListView.builder(
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = filteredCustomers[index];
              final name = customer['Name'];
              final phone = customer['Phone'];
              final address = customer['Address'];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                      icon: Icon(Icons.edit,
                                          color: Colors.lightBlue),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddNewCustomer(
                                              customerId: customer.id, 
                                            ),
                                          ),
                                        );
                                      }),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Delete Customer'),
                                              content: Text(
                                                  'All the data belongs to $name will be deleted'),
                                              actions: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .lightBlue),
                                                        )),
                                                    TextButton(
                                                        onPressed: () {
                                                          customerRef
                                                              .doc(customer.id)
                                                              .delete();
                                                          Navigator.pop(
                                                              context);
                                                          Fluttertoast
                                                              .showToast(
                                                            msg:
                                                                "Customer deleted",
                                                            toastLength: Toast
                                                                .LENGTH_SHORT,
                                                            gravity:
                                                                ToastGravity
                                                                    .BOTTOM,
                                                            backgroundColor:
                                                                Colors.black45,
                                                            textColor:
                                                                Colors.white,
                                                            fontSize: 16.0,
                                                          );
                                                        },
                                                        child: Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )),
                                                  ],
                                                )
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ])
                          ],
                        ),
                        SizedBox(height: 2),
                        Text('Phone: $phone'),
                        Text('Address: $address'),
                        SizedBox(height: 10),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => OrderPage()),
                              );
                            },
                            child: Text('Add New Order'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.lightBlue,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddNewCustomer()));
        },
        label: Text('Add Customer'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        icon: Icon(Icons.add),
      ),
    );
  }
}