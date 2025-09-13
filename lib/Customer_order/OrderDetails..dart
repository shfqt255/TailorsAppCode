// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tailors_application/Customer_order/AddNewCustomer.dart';

class OrderDetails extends StatefulWidget {
  String? CustomerID;
  String? OrderID;
  OrderDetails({super.key, this.CustomerID, this.OrderID});

  @override
  State<OrderDetails> createState() => OrderDetailsState();
}

class OrderDetailsState extends State<OrderDetails> {
  TextEditingController noOfSuitsController = TextEditingController();
  TextEditingController deliveryDateController = TextEditingController();
  TextEditingController amountPerSuitController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();
  TextEditingController advanceAmountController = TextEditingController();
  TextEditingController RemainingAmountController = TextEditingController();
  bool isUrgent = false;
  final formKey = GlobalKey<FormState>();

  bool isloading = true;

  Future<void> Save() async {
    try {
      FirebaseFirestore.instance
          .collection('Customer')
          .doc(widget.CustomerID)
          .collection('Orders')
          .add({
        'Urgent': isUrgent,
        'NumberOfSuits': double.parse(noOfSuitsController.text),
        'DeliveryDate': deliveryDateController.text.trim(),
        'PerSuitAmount': amountPerSuitController.text.trim(),
        'Total Amount': totalAmountController.text.trim(),
        'Advance Amount': advanceAmountController.text.trim(),
        'Remaining Amount': RemainingAmountController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving order: $e')),
      );
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    noOfSuitsController.addListener(CalculatePayments);
    amountPerSuitController.addListener(CalculatePayments);
    totalAmountController.addListener(CalculatePayments);
    advanceAmountController.addListener(CalculatePayments);
//    RemainingAmountController.addListener(CalculatePayments);

    if (widget.OrderID != null) {
      LoadOrderData();
    }
  }

  double NoSuits = 0;
  double AmountPerSuit = 0;
  double TotalAmount = 0;
  double AdvanceAmount = 0;
  double RemainingAmount = 0;

  void CalculatePayments() {
    NoSuits = double.tryParse(noOfSuitsController.text) ?? 0;
    AmountPerSuit = double.tryParse(amountPerSuitController.text) ?? 0;
    TotalAmount = double.tryParse(totalAmountController.text) ?? 0;
    AdvanceAmount = double.tryParse(advanceAmountController.text) ?? 0;
    RemainingAmount = double.tryParse(RemainingAmountController.text) ?? 0;
    double Total = AmountPerSuit * NoSuits;
    totalAmountController.text = Total.toString();
    if (AdvanceAmount <= TotalAmount) {
      double Remaining = TotalAmount - AdvanceAmount;
      RemainingAmountController.text = Remaining.toString();
    } else {
      Fluttertoast.showToast(
          msg: 'Total Amount must be less than or equal to total amount',
          backgroundColor: Colors.black45,
          textColor: Colors.white);
    }
  }

  void LoadOrderData() async {
    setState(() {
      isloading = true; // Add loading state
    });

    try {
      final orderData = await FirebaseFirestore.instance
          .collection('Customer')
          .doc(widget.CustomerID)
          .collection('Orders')
          .doc(widget.OrderID)
          .get();

      if (orderData.exists) {
        final data = orderData.data() as Map<String, dynamic>;

        setState(() {
          // MISSING setState!
          noOfSuitsController.text = data['NumberOfSuits']?.toString() ?? '';
          deliveryDateController.text = data['DeliveryDate'] ?? '';
          amountPerSuitController.text =
              data['PerSuitAmount']?.toString() ?? '';
          totalAmountController.text = data['Total Amount']?.toString() ?? '';
          advanceAmountController.text =
              data['Advance Amount']?.toString() ?? '';
          RemainingAmountController.text =
              data['Remaining Amount']?.toString() ?? '';
          isUrgent = data['Urgent'] ?? false;
          isloading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        isloading = false;
      });
    }
  }

  Future<void> Update() async {
    try {
       FirebaseFirestore.instance
          .collection('Customer')
          .doc(widget.CustomerID)
          .collection('Orders')
          .doc(widget.OrderID)
          .update({
        'Urgent': isUrgent,
        'NumberOfSuits': double.parse(noOfSuitsController.text),
        'DeliveryDate': deliveryDateController.text.trim(),
        'PerSuitAmount': amountPerSuitController.text.trim(),
        'Total Amount': totalAmountController.text.trim(),
        'Advance Amount': advanceAmountController.text.trim(),
        'Remaining Amount': RemainingAmountController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating order: $e')),
      );
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(
    String label,
    TextInputType KeyboardType,
    TextEditingController controller,
  ) {
    return SizedBox(
      child: TextFormField(
        controller: controller,
        keyboardType: KeyboardType,
        inputFormatters: [
          LengthLimitingTextInputFormatter(8),
        ],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '* Required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 15, color: Colors.blueGrey),
          floatingLabelStyle: TextStyle(color: Colors.lightBlue, fontSize: 16),
          filled: true,
          fillColor: Colors.white24,
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.black45,
          )),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue)),
          errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.black45,
          )),
          focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue)),
        ),
        cursorColor: Colors.lightBlue,
        cursorErrorColor: Colors.lightBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details ',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 50, left: 10, right: 10),
        child: GestureDetector(
          onTap: () {
            FocusScopeNode focusScopeNode = FocusScope.of(context);
            if (!focusScopeNode.hasPrimaryFocus) {
              focusScopeNode.unfocus();
            }
          },
          child: Form(
            key: formKey,
            child: ListView(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 15,
                  children: [
                    Text(
                      'Order Details:',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.lightBlue,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: double.infinity),
                    Row(
                      children: [
                        Icon(Icons.checkroom, size: 30, color: Colors.blueGrey),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "No.of suits",
                            TextInputType.number,
                            noOfSuitsController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.date_range,
                            size: 30, color: Colors.blueGrey),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: deliveryDateController,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                String formattedDate =
                                    "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                                setState(() {
                                  deliveryDateController.text = formattedDate;
                                });
                              }
                            },
                            decoration: InputDecoration(
                              labelText: "Delivery Date",
                              labelStyle: TextStyle(color: Colors.blueGrey),
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: Colors.black45,
                              )),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.lightBlue)),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 30, color: Colors.blueGrey),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Amount Per Suit",
                            TextInputType.number,
                            amountPerSuitController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.money, size: 30, color: Colors.blueGrey),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Total Amount",
                            TextInputType.number,
                            totalAmountController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.money_off_csred_outlined,
                            size: 30, color: Colors.blueGrey),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Advance Amount",
                            TextInputType.number,
                            advanceAmountController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.money_off, size: 30, color: Colors.blueGrey),
                        SizedBox(width: 10),
                        Expanded(
                          child: _buildTextField(
                            "Remaining Amount",
                            TextInputType.number,
                            RemainingAmountController,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 150,
                          color: Colors.black12,
                          child: Row(
                            children: [
                              Checkbox(
                                value: isUrgent,
                                onChanged: (value) {
                                  setState(() {
                                    isUrgent = value!;
                                  });
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                activeColor: Colors.lightBlue,
                              ),
                              Text('Mark as Urgent'),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddNewCustomer(
                                        customerId: widget.CustomerID)));
                          },
                          child: Text('Edit Measurements'),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.lightBlue),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            if (widget.OrderID != null) {
                              await Update();
                              Navigator.pop(context);
                            } else if (widget.OrderID == null) {
                              await Save();
                              Navigator.pop(context);
                            }
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Fill all the fields',
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              toastLength: Toast.LENGTH_LONG,
                            );
                          }
                        },
                        child: Text(widget.OrderID != null ? 'Update' : 'Save'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.lightBlue),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(horizontal: 140, vertical: 15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
