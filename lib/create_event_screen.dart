import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Date from calendar
  String _selectedDate = '';

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      }
    });
  }

  String radioValue = "hej";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: Text("Create event"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(
                  top: 15.0, left: 10.0, right: 10.0, bottom: 5.0),
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Event",
                  labelStyle: const TextStyle(color: Colors.white),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Description",
                  labelStyle: const TextStyle(color: Colors.white),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: TextFormField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Date",
                  labelStyle: const TextStyle(color: Colors.white),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10)),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    setState(() {
                      radioValue = "då";
                    });
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Radio(
                          value: "då",
                          groupValue: radioValue,
                          onChanged: (String? value) {
                            setState(() {
                              radioValue = value!;
                            });
                          },
                        ),
                        const Text('då'),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      radioValue = "hej";
                    });
                  },
                  child: Container(
                    child: Row(
                      children: [
                        Radio(
                          value: "hej",
                          groupValue: radioValue,
                          onChanged: (String? value) {
                            setState(() {
                              radioValue = value!;
                            });
                          },
                        ),
                        const Text('då'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  primary: Colors.white24,
                  textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                ),
                onPressed: () {
                  showCupertinoModalBottomSheet(
                    context: context,
                    enableDrag: true,
                    builder: (context) => SingleChildScrollView(
                      controller: ModalScrollController.of(context),
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 30.0, top: 10.0, right: 10.0, left: 10.0),
                        color: Colors.white,
                        child: Column(
                          children: [
                            SfDateRangePicker(
                              selectionColor: Colors.black,
                              todayHighlightColor: Colors.teal,
                              onSelectionChanged: _onSelectionChanged,
                              selectionMode:
                                  DateRangePickerSelectionMode.single,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: const Text("Sign in"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
