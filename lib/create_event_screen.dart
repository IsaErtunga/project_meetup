import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_meetup/application_bloc.dart';
import 'package:project_meetup/google_maps_screen.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:async';
import 'discover_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateEventScreen extends StatefulWidget {
  final Group group;
  const CreateEventScreen(this.group, {Key? key}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  CollectionReference events = FirebaseFirestore.instance.collection('Events');

  // Controller for Google Maps
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> formData = {
    "name": null,
    "description": null,
    "date": null,
    "hostingGroup": null,
    "picture": null,
    "location": null,
    "eventImages": [],
    "attendingUsers": [],
    "numberOfAttendees": null,
  };

  final applicationBloc = ApplicationBloc();

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        formData['date'] = args.value;
      }
    });
  }

  Future<void> addEvent(String hostingGroup) {
    formData["hostingGroup"] = hostingGroup;
    return events
        .add(formData)
        .then((value) => print("Event Added"))
        .catchError((error) => print("Failed to add event: $error"));
  }

  String radioValue = "hej";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        elevation: 0,
        title: Text("Create event"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: const EdgeInsets.symmetric(vertical: 20.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.transparent,
            primary: Colors.white24,
            textStyle: const TextStyle(
                color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
          ),
          onPressed: () {
            print('Submitting form');
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save(); //onSaved is called!
              addEvent(widget.group.id);
            }
          },
          child: const Text("Add event"),
        ),
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
                onSaved: (String? value) {
                  setState(() {
                    formData['name'] = value;
                  });
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
                onSaved: (String? value) {
                  setState(() {
                    formData['description'] = value;
                  });
                },
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Location",
                    labelStyle: const TextStyle(color: Colors.white),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    applicationBloc.searchPlaces(value);
                    applicationBloc.searchResults.forEach((element) {
                      print(element.description);
                    });
                  }),
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
                child: const Text("Select date"),
              ),
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
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return const GoogleMapsScreen();
                      },
                    ),
                  );
                },
                child: const Text("Select date"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
