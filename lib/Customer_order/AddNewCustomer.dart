import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddNewCustomer extends StatefulWidget {
  final String? customerId;
  String? OrderId; // optional
  AddNewCustomer({super.key, this.customerId, this.OrderId});
  @override
  State<AddNewCustomer> createState() => _AddNewCustomerState();
}

class _AddNewCustomerState extends State<AddNewCustomer> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  TextEditingController qameezController = TextEditingController();
  TextEditingController armLengthController = TextEditingController();
  TextEditingController cuffLengthController = TextEditingController();
  TextEditingController cuffWidthController = TextEditingController();
  TextEditingController shoulderLengthController = TextEditingController();
  TextEditingController neckCollarLengthController = TextEditingController();
  TextEditingController chestLengthController = TextEditingController();
  TextEditingController hemDamunLengthController = TextEditingController();
  TextEditingController waistLengthController = TextEditingController();
  TextEditingController shalwarLengthController = TextEditingController();
  TextEditingController panchaLengthController = TextEditingController();
  TextEditingController additionalInfoController = TextEditingController();

  // Checkbox variables
  bool isFrontPocket = false;
  bool isTrouserPockets = false;
  bool isShalwarPocket = false;
  bool isStud = false;
  bool isChakStrip = false;
  List<String> gallaTypes = ['COLLAR', 'BAEN'];
  String? selectedGallaType;
  List<String> SleeveType = [
    'QAF',
    'ROUND',
  ];
  String? selectedSleeveType;
  List<String> HEMTypes = [
    'ROUND',
    'STRAIGHT',
  ];
  String? selectedHEMType;
  List<String> SidePockets = [
    'ONE',
    'TWO',
    'NONE',
  ];
  String? selectedSidePockets;
  bool isEditMode = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null || widget.OrderId != null) {
      isEditMode = true;
      loadCustomerData();
    } else {
      isLoading = false;
    }
  }

  // Future<void> _loadData() async {
  //   try {
  //     await Future.wait([loadCustomerData(), loadMeasurements()]);
  //   } catch (e) {
  //     Fluttertoast.showToast(
  //       msg: 'Error loading data: $e',
  //       backgroundColor: Colors.red,
  //       textColor: Colors.white,
  //     );
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
  CollectionReference Customer =
      FirebaseFirestore.instance.collection('Customer');

  Future<void> loadCustomerData() async {
    try {
      DocumentSnapshot customerDoc =
          await Customer.doc(widget.customerId).get();

      if (customerDoc.exists) {
        Map<String, dynamic> customerData =
            customerDoc.data() as Map<String, dynamic>;

        nameController.text = customerData['Name'] ?? '';
        phoneController.text = customerData['Phone'] ?? '';
        addressController.text = customerData['Address'] ?? '';
        qameezController.text = customerData['qameezLength'] ?? '';
        armLengthController.text = customerData['ArmLength'] ?? '';
        cuffLengthController.text = customerData['CuffLength'] ?? '';
        cuffWidthController.text = customerData['CuffWidth'] ?? '';
        shoulderLengthController.text = customerData['ShoulderLength'] ?? '';
        neckCollarLengthController.text =
            customerData['Neck_CollarLength'] ?? '';
        chestLengthController.text = customerData['ChestLength'] ?? '';
        hemDamunLengthController.text = customerData['HemLength'] ?? '';
        waistLengthController.text = customerData['WaistLength'] ?? '';
        shalwarLengthController.text = customerData['ShalwarLength'] ?? '';
        panchaLengthController.text = customerData['PanchaLength'] ?? '';
        additionalInfoController.text =
            customerData['Additional Information'] ?? '';

        isFrontPocket = customerData['FrontPocket'] ?? false;
        isStud = customerData['Stud'] ?? false;
        isChakStrip = customerData['ChakStrip'] ?? false;

        selectedGallaType = customerData['GallaType'];
        selectedSleeveType = customerData['SleeveType'];
        selectedSidePockets = customerData['Side Pockets'];
        selectedHEMType = customerData['HemType'];
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error loading data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Future<void> loadMeasurements() async {
  //   DocumentSnapshot customerMeasures = await Customer.doc(widget.customerId)
  //       .collection('Measurements')
  //       .doc("Current")
  //       .get();

  //   if (customerMeasures.exists) {
  //     Map<String, dynamic> customerData =
  //         customerMeasures.data() as Map<String, dynamic>;

  //     qameezController.text = customerData['qameezLength'] ?? '';
  //     armLengthController.text = customerData['ArmLength'] ?? '';
  //     cuffLengthController.text = customerData['CuffLength'] ?? '';
  //     cuffWidthController.text = customerData['CuffWidth'] ?? '';
  //     shoulderLengthController.text = customerData['ShoulderLength'] ?? '';
  //     neckCollarLengthController.text = customerData['Neck/CollarLength'] ?? '';
  //     chestLengthController.text = customerData['ChestLength'] ?? '';
  //     hemDamunLengthController.text = customerData['HemLength'] ?? '';
  //     waistLengthController.text = customerData['WaistLength'] ?? '';
  //     shalwarLengthController.text = customerData['ShalwarLength'] ?? '';
  //     panchaLengthController.text = customerData['PanchaLength'] ?? '';
  //     additionalInfoController.text =
  //         customerData['Additional Information'] ?? '';

  //     isFrontPocket = customerData['FrontPocket'] ?? false;
  //     isStud = customerData['Stud'] ?? false;
  //     isChakStrip = customerData['ChakStrip'] ?? false;

  //     selectedGallaType = customerData['GallaType'];
  //     selectedSleeveType = customerData['SleeveType'];
  //     selectedSidePockets = customerData['Side Pockets'];
  //     selectedHEMType = customerData['HemType'];
  //   }
  // }

  Future<void> addUser() async {
    final phone = phoneController.text.trim();
    await Customer.add({
      'Name': nameController.text.trim(),
      'Phone': phone,
      'Address': addressController.text.trim(),
      'qameezLength': qameezController.text.trim(),
      'ArmLength': armLengthController.text.trim(),
      'CuffLength': cuffLengthController.text.trim(),
      'CuffWidth': cuffWidthController.text.trim(),
      'ShoulderLength': shoulderLengthController.text.trim(),
      'Neck_CollarLength': neckCollarLengthController.text.trim(),
      'ChestLength': chestLengthController.text.trim(),
      'HemLength': hemDamunLengthController.text.trim(),
      'WaistLength': waistLengthController.text.trim(),
      'ShalwarLength': shalwarLengthController.text.trim(),
      'PanchaLength': panchaLengthController.text.trim(),
      'FrontPocket': isFrontPocket,
      'Stud': isStud,
      'ChakStrip': isChakStrip,
      'GallaType': selectedGallaType,
      'SleeveType': selectedSleeveType,
      'Side Pockets': selectedSidePockets,
      'HemType': selectedHEMType,
      'Additional Information': additionalInfoController.text.trim(),
      'createdAt': DateTime.now(),
    });
    // return docRef.id;
  }

  Future<void> updateUser() async {
    final phone = phoneController.text.trim();
    await Customer.doc(widget.customerId).update({
      'Name': nameController.text.trim(),
      'Phone': phone,
      'Address': addressController.text.trim(),
      'qameezLength': qameezController.text.trim(),
      'ArmLength': armLengthController.text.trim(),
      'CuffLength': cuffLengthController.text.trim(),
      'CuffWidth': cuffWidthController.text.trim(),
      'ShoulderLength': shoulderLengthController.text.trim(),
      'Neck_CollarLength': neckCollarLengthController.text.trim(),
      'ChestLength': chestLengthController.text.trim(),
      'HemLength': hemDamunLengthController.text.trim(),
      'WaistLength': waistLengthController.text.trim(),
      'ShalwarLength': shalwarLengthController.text.trim(),
      'PanchaLength': panchaLengthController.text.trim(),
      'FrontPocket': isFrontPocket,
      'Stud': isStud,
      'ChakStrip': isChakStrip,
      'GallaType': selectedGallaType,
      'SleeveType': selectedSleeveType,
      'Side Pockets': selectedSidePockets,
      'HemType': selectedHEMType,
      'Additional Information': additionalInfoController.text.trim(),
      'UpdatedAt': DateTime.now(),
    });
  }

  // Future<void> updateMeasurements() async {
  //   final measurementsRef = await FirebaseFirestore.instance
  //       .collection('Customer')
  //       .doc(widget.customerId)
  //       .collection('Measurements').doc("Current")
  //       .get();
  //   var Mid;
  //   for (var docid in measurementsRef.docs) {
  //     Mid = docid;
  //   }
  //   await FirebaseFirestore.instance
  //       .collection('Customer')
  //       .doc(widget.customerId)
  //       .collection('Measurements')
  //       .doc(Mid)
  //       .update(
  //     {
  //       'qameezLength': qameezController.text.trim(),
  //       'ArmLength': armLengthController.text.trim(),
  //       'CuffLength': cuffLengthController.text.trim(),
  //       'CuffWidth': cuffWidthController.text.trim(),
  //       'ShoulderLength': shoulderLengthController.text.trim(),
  //       'Neck/CollarLength': neckCollarLengthController.text.trim(),
  //       'ChestLength': chestLengthController.text.trim(),
  //       'HemLength': hemDamunLengthController.text.trim(),
  //       'WaistLength': waistLengthController.text.trim(),
  //       'ShalwarLength': shalwarLengthController.text.trim(),
  //       'PanchaLength': panchaLengthController.text.trim(),
  //       'FrontPocket': isFrontPocket,
  //       'Stud': isStud,
  //       'ChakStrip': isChakStrip,
  //       'GallaType': selectedGallaType,
  //       'SleeveType': selectedSleeveType,
  //       'Side Pockets': selectedSidePockets,
  //       'HemType': selectedHEMType,
  //       'Additional Information': additionalInfoController.text.trim(),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     },
  //   );
  // }

  // Future<void> saveMeasurements() async {
  //   final measurementsRef = FirebaseFirestore.instance
  //       .collection("Customer")
  //       .doc(widget.customerId)
  //       .collection("Measurements")
  //       .doc("Current");
  //   await measurementsRef.set(
  //     {
  //       'qameezLength': qameezController.text.trim(),
  //       'ArmLength': armLengthController.text.trim(),
  //       'CuffLength': cuffLengthController.text.trim(),
  //       'CuffWidth': cuffWidthController.text.trim(),
  //       'ShoulderLength': shoulderLengthController.text.trim(),
  //       'Neck/CollarLength': neckCollarLengthController.text.trim(),
  //       'ChestLength': chestLengthController.text.trim(),
  //       'HemLength': hemDamunLengthController.text.trim(),
  //       'WaistLength': waistLengthController.text.trim(),
  //       'ShalwarLength': shalwarLengthController.text.trim(),
  //       'PanchaLength': panchaLengthController.text.trim(),
  //       'FrontPocket': isFrontPocket,
  //       'Stud': isStud,
  //       'ChakStrip': isChakStrip,
  //       'GallaType': selectedGallaType,
  //       'SleeveType': selectedSleeveType,
  //       'Side Pockets': selectedSidePockets,
  //       'HemType': selectedHEMType,
  //       'Additional Information': additionalInfoController.text.trim(),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     },
  //   );
  // }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    qameezController.dispose();
    armLengthController.dispose();
    cuffLengthController.dispose();
    cuffWidthController.dispose();
    shoulderLengthController.dispose();
    neckCollarLengthController.dispose();
    chestLengthController.dispose();
    hemDamunLengthController.dispose();
    waistLengthController.dispose();
    shalwarLengthController.dispose();
    panchaLengthController.dispose();
    additionalInfoController.dispose();
    super.dispose();
  }

  Widget buildSimpleTexfield(String? Label, TextEditingController controller,
      TextInputType KeyboardType) {
    return TextFormField(
        controller: controller,
        keyboardType: KeyboardType,
        decoration: InputDecoration(
            labelText: Label,
            labelStyle: TextStyle(color: Colors.blueGrey, fontSize: 14),
            floatingLabelStyle:
                TextStyle(color: Colors.lightBlue, fontSize: 16),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45, width: 0.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue, width: 1),
            )),
        cursorColor: Colors.lightBlue,
        cursorErrorColor: Colors.lightBlue,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '* Required field';
          } else {
            return null;
          }
        });
  }

  Widget buildIcon(IconData icon) {
    return Icon(
      icon,
      color: Colors.black45,
      size: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(isEditMode ? 'Edit Customer' : 'Add New Customer'),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          backgroundColor: Colors.lightBlue,
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : GestureDetector(
                onTap: () {
                  FocusScopeNode focusScopeNode = FocusScope.of(context);
                  if (!focusScopeNode.hasPrimaryFocus) {
                    focusScopeNode.unfocus();
                  }
                },
                child: Form(
                    key: formKey,
                    child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 30),
                        child: ListView(children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 15,
                            children: [
                              Text(
                                'Customer Details:',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 20),
                              Row(children: [
                                buildIcon(Icons.person),
                                SizedBox(width: 10),
                                Expanded(
                                    child: buildSimpleTexfield('Name',
                                        nameController, TextInputType.text)),
                              ]),
                              Row(children: [
                                buildIcon(Icons.phone),
                                SizedBox(width: 10),
                                Expanded(
                                    child: buildSimpleTexfield('Phone',
                                        phoneController, TextInputType.phone))
                              ]),
                              Row(children: [
                                buildIcon(Icons.location_on),
                                SizedBox(width: 10),
                                Expanded(
                                    child: buildSimpleTexfield(
                                        'Address',
                                        addressController,
                                        TextInputType.streetAddress)),
                              ]),
                              SizedBox(height: 40),
                              Text(
                                'Qameez Measurements:',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  "Qameez",
                                  qameezController,
                                  TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  "Arm Length",
                                  armLengthController,
                                  TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                    "Cuff/OpenSleeve Length",
                                    cuffLengthController,
                                    TextInputType.number),
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  "Cuff  Width",
                                  cuffWidthController,
                                  TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  "Shoulder Length",
                                  shoulderLengthController,
                                  TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  "Neck/Collar Length",
                                  neckCollarLengthController,
                                  TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  "Chest Length",
                                  chestLengthController,
                                  TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  " Hem/DamunLength",
                                  hemDamunLengthController,
                                  TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  "Waist Length",
                                  waistLengthController,
                                  TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Shalwar Measurements:',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  "Shalwar Length",
                                  shalwarLengthController,
                                  TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                width: 165,
                                height: 60,
                                child: buildSimpleTexfield(
                                  "Pancha Length",
                                  panchaLengthController,
                                  TextInputType.number,
                                ),
                              ),
                              Text(
                                'More Informations:',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.bold),
                              ),
                              Row(children: [
                                Container(
                                    width: 150,
                                    color: Colors.black12,
                                    child: Row(children: [
                                      Checkbox(
                                        value: isFrontPocket,
                                        onChanged: (value) {
                                          setState(() {
                                            isFrontPocket = value!;
                                          });
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        activeColor: Colors.lightBlue,
                                      ),
                                      Text('FrontPocket'),
                                    ])),
                                SizedBox(width: 40),
                                Container(
                                    width: 150,
                                    color: Colors.black12,
                                    child: Row(children: [
                                      Checkbox(
                                        value: isStud,
                                        onChanged: (value) {
                                          setState(() {
                                            isStud = value!;
                                          });
                                        },
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        activeColor: Colors.lightBlue,
                                      ),
                                      Text('Stud'),
                                    ])),
                              ]),
                              Container(
                                  width: 150,
                                  color: Colors.black12,
                                  child: Row(children: [
                                    Checkbox(
                                      value: isChakStrip,
                                      onChanged: (value) {
                                        setState(() {
                                          isChakStrip = value!;
                                        });
                                      },
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      activeColor: Colors.lightBlue,
                                    ),
                                    Text('Chak Strip'),
                                  ])),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Galla Type: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        setState(() {
                                          selectedGallaType = value;
                                        });
                                      },
                                      itemBuilder: (context) =>
                                          gallaTypes.map((type) {
                                        return PopupMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                            selectedGallaType ?? "Galla Type"),
                                      ),
                                    ),
                                    Text(
                                      'Sleeve: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        FocusScope.of(context).unfocus();
                                        setState(() {
                                          selectedSleeveType = value;
                                        });
                                      },
                                      itemBuilder: (context) =>
                                          SleeveType.map((type) {
                                        return PopupMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(selectedSleeveType ??
                                            "Sleeve Type"),
                                      ),
                                    ),
                                  ]),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Side Pockets: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        setState(() {
                                          selectedSidePockets = value;
                                        });
                                      },
                                      itemBuilder: (context) =>
                                          SidePockets.map((type) {
                                        return PopupMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(selectedSidePockets ??
                                            "Side Pockets"),
                                      ),
                                    ),
                                    Text(
                                      'HEM: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        setState(() {
                                          selectedHEMType = value;
                                        });
                                      },
                                      itemBuilder: (context) =>
                                          HEMTypes.map((type) {
                                        return PopupMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(selectedHEMType ?? "HEM"),
                                      ),
                                    ),
                                  ]),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Additional Information:',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: additionalInfoController,
                            minLines: null,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              labelText: 'Additional Information',
                              floatingLabelStyle:
                                  TextStyle(color: Colors.lightBlue),
                              alignLabelWithHint: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 1.5),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () async {
  // Check if form state exists before trying to validate
  final currentState = formKey.currentState;
  if (currentState == null) {
    Fluttertoast.showToast(
      msg: 'Form not ready. Please try again.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.white,
      backgroundColor: Colors.red,
    );
    return;
  }
  
  // Now validate the form
  if (currentState.validate()) {
    try {
      if (isEditMode) {
          Navigator.pop(context);
        await updateUser();
        Fluttertoast.showToast(
          msg: 'Customer Updated Successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Colors.blueGrey,
        );
      } else {
          Navigator.pop(context);
        await addUser();
        Fluttertoast.showToast(
          msg: 'Customer Added',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Colors.blueGrey,
        );
      }
      Navigator.pop(context);
    } catch (e) {
      print('Save/Update Error: $e');
      // Fluttertoast.showToast(
      //   msg: 'Error: $e',
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   textColor: Colors.white,
      //   backgroundColor: Colors.red,
      // );
    }
  }
},
                            child: Text(isEditMode ? 'Update' : 'Save'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.lightBlue,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                )),
                          ),
                          SizedBox(height: 30),
                        ])))));
  }
}
