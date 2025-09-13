// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Workers extends StatefulWidget {
  const Workers({super.key});

  @override
  State<Workers> createState() => WorkersState();
}

class WorkersState extends State<Workers> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController NameController = TextEditingController();
  final TextEditingController IDcardController = TextEditingController();
  final TextEditingController PhoneController = TextEditingController();
  final TextEditingController AmountPerSuitController = TextEditingController();
  Widget _buildTextField(String? label, TextInputType inputType,
      TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextFormField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(fontSize: 15, color: Colors.blueGrey),
            floatingLabelStyle:
                const TextStyle(fontSize: 16, color: Colors.lightBlue),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue, width: 1.5),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black45),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.lightBlue, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '* Required field';
            }
            return null;
          },
          cursorColor: Colors.lightBlue,
          cursorErrorColor: Colors.lightBlue,
        ),

    );
  }

  // Save worker details to Firestore
  saveWorkerData() async {
    if (formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('workers').add({
        'name': NameController.text,
        'cnic': IDcardController.text,
        'phone': PhoneController.text,
        'AmountPerSuit': AmountPerSuitController.text,
        'RemainingAmount': 0,
        'createdAt': DateTime.now(),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Worker saved successfully!')),
    );
  }
 @override
  void dispose() {
    NameController.dispose();
    IDcardController.dispose();
    PhoneController.dispose();
    AmountPerSuitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Workers'),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Form(
            key: formKey,
            child: ListView(
              // shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                // const SizedBox(height: 20),
                _buildTextField('Name', TextInputType.text, NameController),
                _buildTextField('CNIC', TextInputType.number, IDcardController),
                _buildTextField('Phone', TextInputType.phone, PhoneController),
                _buildTextField('AmountPerSuit', TextInputType.number,
                    AmountPerSuitController),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if(formKey.currentState!=null && formKey.currentState!.validate()){
                       Navigator.pop(context);
                            saveWorkerData();
                    }
                  
                  },
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.lightBlue),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
