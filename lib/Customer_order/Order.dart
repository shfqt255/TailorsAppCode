// ignore_for_file: unnecessary_cast
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tailors_application/Customer_order/OrderDetails..dart';
import 'package:tailors_application/Customer_order/ViewOrder.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPage extends StatefulWidget {
  String? orderId;
  OrderPage({super.key, this.orderId});
  @override
  State<OrderPage> createState() => orderState();
}

class orderState extends State<OrderPage> {
  CollectionReference CustomerRef =
      FirebaseFirestore.instance.collection('Customer');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isSearching = false;

  // Status filter variables
  String _selectedStatus = 'Received';
  final List<String> _statusOptions = [
    'Received',
    'Processing',
    'Completed',
    'Delivered'
  ];

  @override
  void initState() {
    super.initState();
    // Listen to search text changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Check if customer name or phone matches search text
  bool _matchesSearch(String? customerName, String? customerPhone) {
    if (_searchQuery.isEmpty) return true;

    final name = (customerName ?? '').toLowerCase();
    final phone = (customerPhone ?? '').toLowerCase();

    return name.contains(_searchQuery) || phone.contains(_searchQuery);
  }

  // Check if order status matches selected tab
  bool _matchesStatus(Map<String, dynamic> orderData) {
    final String orderStatus = orderData['Status'] ?? 'Received';
    return orderStatus == _selectedStatus;
  }

  // Update order status in database
  Future<void> _updateOrderStatus(
      String customerId, String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('Customer')
          .doc(customerId)
          .collection('Orders')
          .doc(orderId)
          .update({'Status': newStatus});

      Fluttertoast.showToast(
        msg: 'Order status updated to $newStatus',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update status: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  // Show dialog to update order status
  void _showStatusUpdateDialog(
      String customerId, String orderId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Status: $currentStatus'),
            SizedBox(height: 16),
            Text('Select new status:'),
            SizedBox(height: 10),

            // Processing button
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateOrderStatus(customerId, orderId, 'Processing');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Processing'),
              ),
            ),

            // Completed button
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _updateOrderStatus(customerId, orderId, 'Completed');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Completed'),
              ),
            ),

            // Delivered button
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 8),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Update Remaining Amount'),
                          content:
                              Text('This will update the Financial Record'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDetails(
                                        CustomerID: customerId,
                                        OrderID: orderId,
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Update Amount',
                                  style: TextStyle(color: Colors.lightBlue),
                                )),
                            TextButton(
                                onPressed: () {
                                  if (_selectedStatus == 'Delivered') {
                                    Navigator.pop(context);
                                    _showStatusUpdateDialog(
                                        customerId, orderId, currentStatus);
                                  } else {
                                    Navigator.pop(context);
                                    _updateOrderStatus(
                                        customerId, orderId, 'Delivered');
                                  }
                                },
                                child: Text(
                                  'Update Status',
                                  style: TextStyle(color: Colors.lightBlue),
                                )),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        );
                      });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(_selectedStatus == 'Delivered'
                    ? 'Update Amount'
                    : 'Delivered'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // Show dialog to select customer for new order
  void _showCustomerDialog() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Customer').get();

    String dialogSearchQuery = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Filter customers based on dialog search
          final filteredCustomers = snapshot.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final customerName = (data['Name'] ?? '').toLowerCase();
            final customerPhone = (data['Phone'] ?? '').toLowerCase();

            if (dialogSearchQuery.isEmpty) return true;

            return customerName.contains(dialogSearchQuery.toLowerCase()) ||
                customerPhone.contains(dialogSearchQuery.toLowerCase());
          }).toList();

          return Dialog(
            insetPadding: EdgeInsets.all(10),
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: Column(
                children: [
                  // Header with title and close button
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select a Customer',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  // Search field
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by name or phone',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          dialogSearchQuery = value;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // Customer list
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final doc = filteredCustomers[index];
                        final data = doc.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(data['Name'] ?? 'No Name'),
                          subtitle: Text(data['Phone'] ?? 'No Phone'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OrderDetails(CustomerID: doc.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Navigate to edit OrderDetailss page

  // Make phone call
  void _makeCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    launchUrl(phoneUri);
  }

  // Open WhatsApp chat
  void _openWhatsApp(String phoneNumber) async {
    String formattedPhone = phoneNumber;

    // Convert Pakistani number format
    if (phoneNumber.startsWith('0')) {
      formattedPhone = '92' + phoneNumber.substring(1);
    }

    String whatsappUrl = "https://wa.me/$formattedPhone";
    final Uri whatsappUri = Uri.parse(whatsappUrl);

    await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                cursorColor: Colors.white,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search By name or phone',
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Text(
                'Orders',
                style: TextStyle(fontSize: 20),
              ),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.clear : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  isSearching = true;
                }
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Status tabs section
          Container(
            height: 55,
            child: Row(
              children: _statusOptions.map((status) {
                final bool isSelected = status == _selectedStatus;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.lightBlue
                            : Colors.grey.shade200,
                        border: Border(
                          bottom: BorderSide(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade600,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Orders list section
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Customer').snapshots(),
              builder: (context, snapshot) {
                // Show loading indicator
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Show message if no data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No Orders Found'));
                }

                // Filter customers based on search
                final filteredCustomers =
                    snapshot.data!.docs.where((customerDoc) {
                  final customerData =
                      customerDoc.data() as Map<String, dynamic>;
                  final customerName = customerData['Name'];
                  final customerPhone = customerData['Phone'];
                  return _matchesSearch(customerName, customerPhone);
                }).toList();

                // Show no results message
                if (filteredCustomers.isEmpty && _searchQuery.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No results found for "$_searchQuery"',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                // Build orders list
                return ListView(
                  children: filteredCustomers.map((customerDoc) {
                    final customerData =
                        customerDoc.data() as Map<String, dynamic>;
                    final customerName = customerData['Name'] ?? 'No Name';
                    final customerPhone = customerData['Phone'] ?? 'No Phone';

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Customer')
                          .doc(customerDoc.id)
                          .collection('Orders')
                          .snapshots(),
                      builder: (context, orderSnapshot) {
                        // Skip if no orders
                        if (!orderSnapshot.hasData ||
                            orderSnapshot.data!.docs.isEmpty) {
                          return SizedBox();
                        }

                        // Filter orders by selected status (unless searching)
                        final filteredOrders =
                            orderSnapshot.data!.docs.where((orderDoc) {
                          final orderData =
                              orderDoc.data() as Map<String, dynamic>;

                          // If searching, show all orders for matching customers
                          if (_searchQuery.isNotEmpty) {
                            return true;
                          }

                          // If not searching, filter by status
                          return _matchesStatus(orderData);
                        }).toList();

                        // Skip if no orders match status
                        if (filteredOrders.isEmpty) {
                          return SizedBox();
                        }

                        // Build order cards
                        return Column(
                          children: filteredOrders.map((orderDoc) {
                            final orderData =
                                orderDoc.data() as Map<String, dynamic>;

                            // Get order information
                            final bool isUrgent = orderData['Urgent'] ?? false;
                            final String deliveryDate =
                                orderData['DeliveryDate'] ?? 'No Date';
                            final int numberOfSuits = int.tryParse(
                                    orderData['NumberOfSuits']?.toString() ??
                                        '0') ??
                                0;
                            final String currentStatus =
                                orderData['Status'] ?? 'Received';

                            return Card(
                              margin: EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Customer name and action buttons row
                                    Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "$customerName",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.lightBlue,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _makeCall(customerPhone),
                                            icon: Icon(Icons.call,
                                                size: 20,
                                                color: Colors.lightBlue),
                                          ),
                                          // WhatsApp button
                                          IconButton(
                                            onPressed: () =>
                                                _openWhatsApp(customerPhone),
                                            icon: Icon(Icons.chat,
                                                size: 20,
                                                color: Colors.lightBlue),
                                          ),
                                          // Edit button
                                          IconButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      OrderDetails(
                                                    CustomerID: customerDoc.id,
                                                    OrderID: orderDoc.id,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.edit,
                                                size: 20,
                                                color: Colors.lightBlue),
                                          ),
                                          IconButton(
                                            onPressed: () async {
                                              // Confirm before deleting
                                              final confirm = await showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: Text("Delete Order"),
                                                  content: Text(
                                                      "Are you sure you want to delete this order?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, false),
                                                      child: Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context, true),
                                                      child: Text("Delete",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                try {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Customer')
                                                      .doc(customerDoc
                                                          .id) // parent customer
                                                      .collection('Orders')
                                                      .doc(orderDoc
                                                          .id) // this order
                                                      .delete();

                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Order deleted successfully",
                                                    backgroundColor:
                                                        Colors.green,
                                                    textColor: Colors.white,
                                                  );
                                                } catch (e) {
                                                  Fluttertoast.showToast(
                                                    msg:
                                                        "Failed to delete order: $e",
                                                    backgroundColor: Colors.red,
                                                    textColor: Colors.white,
                                                  );
                                                }
                                              }
                                            },
                                            icon: Icon(Icons.delete,
                                                size: 20, color: Colors.red),
                                          ),
                                        ]),

                                    // Order details
                                    Text("Phone: $customerPhone"),
                                    SizedBox(height: 5),
                                    Text("Delivery Date: $deliveryDate"),
                                    Text("Status: $currentStatus"),
                                    Text("Urgent: ${isUrgent ? 'Yes' : 'No'}"),
                                    Text("Number of Suits: $numberOfSuits"),
                                    SizedBox(height: 10),

                                    // Action buttons row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _showStatusUpdateDialog(
                                                customerDoc.id,
                                                orderDoc.id,
                                                currentStatus);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightBlue,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                              _selectedStatus == 'Delivered'
                                                  ? 'Update Amount'
                                                  : 'Update Status'),
                                        ),
                                        SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderView(
                                                          CustomerID:
                                                              customerDoc.id,
                                                          OrderID: orderDoc.id,
                                                        )));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightBlue,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text('Order Details'),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCustomerDialog,
        label: Text('Add Order', style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
