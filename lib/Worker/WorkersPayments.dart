import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkersPayments extends StatefulWidget {
  final String workerId;
  const WorkersPayments({super.key, required this.workerId});

  @override
  State<WorkersPayments> createState() => _WorkersPaymentsState();
}

class _WorkersPaymentsState extends State<WorkersPayments> {
  int amountPerSuit = 0;
  int remainingAmount = 0;
  int NoSuits = 0;

  final TextEditingController remainingAmountController = TextEditingController();
  final TextEditingController paidAmountController = TextEditingController();
  final TextEditingController NoSuitsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWorkerData();

    paidAmountController.addListener(() {
      setState(() {
        int currentPaid = int.tryParse(paidAmountController.text) ?? 0;
        remainingAmountController.text =
            (remainingAmount - currentPaid).toString();
      });
    });
  }

  Future<void> fetchWorkerData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(widget.workerId)
          .get();

      if (doc.exists) {
        amountPerSuit = int.tryParse(doc['AmountPerSuit'].toString()) ?? 0;
        remainingAmount = int.tryParse(doc['RemainingAmount'].toString()) ?? 0;

        remainingAmountController.text = remainingAmount.toString();
        paidAmountController.clear();
        NoSuitsController.clear();
        NoSuits = 0;
      }
    } catch (e) {
      print("Error fetching worker data: $e");
    }
  }

  void increment() {
    setState(() {
      NoSuits++;
      NoSuitsController.text = NoSuits.toString();
      remainingAmount += amountPerSuit;
      remainingAmountController.text = remainingAmount.toString();
    });
  }

  void decrement() {
    setState(() {
      if (NoSuits > 0) {
        NoSuits--;
        NoSuitsController.text = NoSuits.toString();
        remainingAmount -= amountPerSuit;
        remainingAmountController.text = remainingAmount.toString();
      }
    });
  }

Future<void> savePayment() async {
  try {
    int paidNow = int.tryParse(paidAmountController.text) ?? 0;
    remainingAmount -= paidNow;

    // Create references first
    final workerRef = FirebaseFirestore.instance.collection('workers').doc(widget.workerId);
    final paymentsRef = workerRef.collection('Payments').doc();

    // Prepare batch write (saves both together, works offline)
    final batch = FirebaseFirestore.instance.batch();

    batch.set(paymentsRef, {
      'Paid Amount': paidNow,
      'Suits Added': NoSuits,
      'Remaining After Payment': remainingAmount,
      'Date': DateTime.now(),
    });

    batch.update(workerRef, {
      'RemainingAmount': remainingAmount,
    });

    // Commit but don't await
    batch.commit(); //  no await, so it queues offline

    // Pop immediately
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment saved (will sync when online).")),
    );
  } catch (e) {
    print("Error saving payment: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

  Widget buildTextFormField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        floatingLabelStyle: TextStyle(color: Colors.lightBlue),
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
          cursorColor: Colors.lightBlue,
          cursorErrorColor: Colors.lightBlue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Worker Payments", ), backgroundColor: Colors.lightBlue, foregroundColor: Colors.white,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 TextButton(
                 child: Text('- Suit ', style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 style: TextButton.styleFrom(
                     backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                 ),
                  onPressed: decrement,
                ),
                SizedBox(
                  height: 40, width: 150,
                  child: buildTextFormField(
                    label: "No. of Suits",
                    controller: NoSuitsController,
                    readOnly: true,
                  ),
                ),
               
                 TextButton(
                 child: Text('+ Suit ', style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                 style: TextButton.styleFrom(
                     backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                 ),
                  onPressed: increment,
                ),
              ],
            ),
            SizedBox(height: 20,),
            buildTextFormField(
              label: "Remaining Amount",
              controller: remainingAmountController,
              readOnly: true,
            ),
            const SizedBox(height: 16),

            buildTextFormField(
              label: "Paid Amount",
              controller: paidAmountController,
            ),
            const SizedBox(height: 16),

          
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: savePayment,
              child: const Text("Save Payment"),
              style: TextButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
