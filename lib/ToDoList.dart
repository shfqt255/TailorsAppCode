// ignore_for_file: unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToDoList extends StatefulWidget {
  ToDoList({super.key});
  @override
  State<ToDoList> createState() => ToDoListState();
}

class ToDoListState extends State<ToDoList> {
  TextEditingController TaskController = TextEditingController();
  TextEditingController DescriptionController = TextEditingController();
  DateTime? SelectedDate;
  TimeOfDay? SelectedTime;
  String? FormattedDate;
  String? FormattedTime;
  bool isFinish = false;
  bool showFinishedTask = false;
  // Show date picker
  void showDateTime() async {
    DateTime? datePicker = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context),
          child: Theme(data: ThemeData.dark(), child: child!),
        );
      },
    );

    if (datePicker != null) {
      setState(() {
        SelectedDate = datePicker;
        FormattedDate = DateFormat('d MMMM yyyy').format(datePicker);
      });
    }
  }

  // Show time picker
  void TimePicker() async {
    TimeOfDay? timePicker = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: Theme(data: ThemeData.dark(), child: child!),
        );
      },
    );

    if (timePicker != null) {
      setState(() {
        SelectedTime = timePicker;
        final now = DateTime.now();
        final dt = DateTime(
            now.year, now.month, now.day, timePicker.hour, timePicker.minute);
        FormattedTime = DateFormat.jm().format(dt); // e.g., "12:16 PM"
      });
    }
  }

  // TextField builder
  Widget builtTextField(
      String hintText, TextEditingController controller, int showlines) {
    return TextField(
      style: TextStyle(color: Colors.white),
      maxLines: showlines,
      controller: controller,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
      cursorColor: Colors.white,
    );
  }

  // Firebase Store
  CollectionReference TaskRef =
      FirebaseFirestore.instance.collection('TasksList');

  Future<void> storeData() async {
    await TaskRef.add({
      'Task Name': TaskController.text.trim(),
      'Description': DescriptionController.text.trim(),
      'Date': FormattedDate, // nullable is OK
      'Time': FormattedTime, // nullable is OK
      'Finish': isFinish,
    });

    // Clear fields
    TaskController.clear();
    DescriptionController.clear();
    FormattedDate = null;
    FormattedTime = null;
    SelectedDate = null;
    SelectedTime = null;
  }

  void showBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.lightBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      barrierColor: Colors.white,
      context: context,
      // isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 500,
          // child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              builtTextField('Task Name', TaskController, 1),
              SizedBox(height: 10),
              builtTextField('Description', DescriptionController, 2),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: showDateTime,
                    icon: Icon(Icons.date_range_outlined, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: TimePicker,
                    icon: Icon(Icons.access_time, color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () {
                      storeData();
                      Navigator.pop(context);
                    },
                    child: Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              if (FormattedDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Date: $FormattedDate",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              if (FormattedTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "Time: $FormattedTime",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          //    ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks List',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  showFinishedTask = !showFinishedTask;
                });
              },
              child: Text(
                showFinishedTask ? 'All' : 'Finished',
                style: TextStyle(color: Colors.white),
              ))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: TaskRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final tasks = snapshot.data?.docs ?? [];
            if (tasks.isEmpty) {
              return Center(
                child: Text('No Tasks Added'),
              );
            }
            if (snapshot.hasError) {
              Fluttertoast.showToast(msg: 'Error: ${snapshot.error}');
            }
            final filteredTasks = tasks.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final isFinished = data['Finish'] ?? false;
              return showFinishedTask ? isFinished : !isFinished;
            }).toList();
            return ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                final taskData =
                    filteredTasks[index].data() as Map<String, dynamic>;
                final TaskName = taskData['Task Name'] ?? '';
                final TaskDescription = taskData['Description'] ?? '';
                final TaskDate = taskData['Date'] ?? '';
                final TaskTime = taskData['Time'] ?? '';
                final isFinished = taskData['Finish'] ?? false;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(10)),
                  color: Colors.blueGrey,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$TaskName',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          '$TaskDescription',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Date: $TaskDate, ',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Time: $TaskTime',
                          style: TextStyle(color: Colors.white),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () async {
                                  try {
                                    await TaskRef.doc(filteredTasks[index].id)
                                        .update({'Finish': true});

                                    setState(() {});
                                    Fluttertoast.showToast(
                                        msg: 'Task Finished',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.black45,
                                        textColor: Colors.white);
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg: 'Error: $e',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.black45,
                                        textColor: Colors.white);
                                  }
                                },
                                child: Text(
                                  'Finish',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                            TextButton(
                                onPressed: () async {
                                  try {
                                    await TaskRef.doc(filteredTasks[index].id)
                                        .delete();
                                    Fluttertoast.showToast(
                                        msg: 'Task Deleted',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.black45,
                                        textColor: Colors.white);
                                  } catch (e) {
                                    Fluttertoast.showToast(
                                        msg: 'Error: $e',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.black45,
                                        textColor: Colors.white);
                                  }
                                },
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: showBottomSheet,
        child: Icon(Icons.add, size: 30),
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
