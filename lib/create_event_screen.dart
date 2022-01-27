import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_meetup/application_bloc.dart';
import 'package:project_meetup/google_maps_screen.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
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

  bool _pressed = false;

  // Formatted strings for date button
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String formattedString = "";

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        // Set form state
        formData['date'] = args.value;

        // Set button string value
        formattedString = formatter.format(args.value);
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
      resizeToAvoidBottomInset:
          false, //used to ovoid bottomoverflow, but now button does not move above keyboard anymore at all
      backgroundColor: Colors.black, //Colors.deepPurple.withOpacity(0.4),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.withOpacity(0),
        elevation: 0,
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
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  labelStyle: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontFamily: 'verdana_regular',
                    fontWeight: FontWeight.w400,
                  ),
                  floatingLabelStyle: TextStyle(color: Colors.greenAccent),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFFFFEBEE)),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  prefixIcon: Icon(Icons.keyboard_arrow_right_rounded,
                      color: Colors.greenAccent),
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
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontFamily: 'verdana_regular',
                    fontWeight: FontWeight.w400,
                  ),
                  floatingLabelStyle: TextStyle(color: Colors.greenAccent),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  filled: false,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: const Color(0xFFFFEBEE)),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  prefixIcon:
                      Icon(Icons.textsms_outlined, color: Colors.greenAccent),
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
              child: TextFormField(
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      fontFamily: 'verdana_regular',
                      fontWeight: FontWeight.w400,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    floatingLabelStyle: TextStyle(color: Colors.greenAccent),
                    filled: false,
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: const Color(0xFFFFEBEE)),
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.greenAccent, width: 1.5),
                      borderRadius: BorderRadius.all(Radius.circular(25)),
                    ),
                    prefixIcon: Icon(
                      Icons.edit_location_outlined,
                      color: Colors.greenAccent,
                    ),
                  ),
                  onChanged: (value) {
                    applicationBloc.searchPlaces(value);
                    applicationBloc.searchResults.forEach((element) {
                      print(element.description);
                    });
                  }),
            ),
            SizedBox(height: 30),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.transparent,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(50),
                    textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 35, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    side: BorderSide(color: Color(0xFFFFEBEE))),
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
                              todayHighlightColor: Colors.greenAccent,
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
                child: Stack(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.calendar_today_rounded,
                            color: Colors.greenAccent)),
                    Align(
                      alignment: Alignment.center,
                      child: formData["date"] != null
                          ? Text(formattedString)
                          : Text("SELECT DATE",
                              style: TextStyle(color: Colors.greenAccent)),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  side: BorderSide(color: const Color(0xFFFFEBEE)),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) {
                        return GoogleMapsScreen();
                      },
                    ),
                  );
                },
                child: Stack(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.location_on_outlined,
                            color: Colors.greenAccent)),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "SELECT LOCATION",
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(flex: 3),
            Container(
              margin: EdgeInsets.only(bottom: 30.0, right: 10, left: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  side: BorderSide(
                      color: Colors
                          .deepPurple), //(color: const Color(0xFFFFEBEE)),
                  minimumSize: const Size.fromHeight(50),
                  primary: Colors.deepPurple, //Colors.white30,
                  textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                ),
                onPressed: () {
                  print('Submitting form');
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save(); //onSaved is called!
                    addEvent(widget.group.id);
                  }
                },
                child: Stack(
                  children: <Widget>[
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(Icons.publish_rounded,
                            color: Colors.greenAccent)),
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        "PUBLISH EVENT",
                        style: TextStyle(color: Colors.greenAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
