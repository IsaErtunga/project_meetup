import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_meetup/application_bloc.dart';
import 'package:project_meetup/google_maps_screen.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
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

  final _formKey = GlobalKey<FormState>();

  final Map<String, dynamic> formData = {
    "eventName": null,
    "description": null,
    "dateTime": null,
    "hostingGroup": null,
    "eventPicture": "https://picsum.photos/200",
    "location": null,
    "participants": [],
    "isPrivate": true,
  };

  // Formatted strings for dateTime button
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  String formattedString = "";

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is DateTime) {
        // Set form state
        formData['dateTime'] = args.value;

        // Set button string value
        formattedString = formatter.format(args.value);
      }
    });
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      final reference = FirebaseStorage.instance.ref(name);
      await reference.putFile(file);
      final uri = await reference.getDownloadURL();
      setState(() {
        formData["eventPicture"] = uri;
      });
    }
  }

  Future<void> addEvent() {
    return events
        .add(formData)
        .then((value) => print("Event Added"))
        .catchError((error) => print("Failed to add event: $error"));
  }

  Future<void> addEventBatch() {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    final String eventId = const Uuid().v4();

    // event document reference
    DocumentReference newEvent =
        FirebaseFirestore.instance.collection('Events').doc(eventId);
    batch.set(newEvent, formData);

    DocumentReference newGroupEvent =
        FirebaseFirestore.instance.collection('Groups').doc(widget.group.id);
    batch.update(newGroupEvent, {
      "events": FieldValue.arrayUnion([
        {
          "eventName": formData["eventName"],
          "id": eventId,
          "image": formData["eventPicture"]
        }
      ])
    });

    return batch.commit();
  }

  bool isPrivate = true;

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
      resizeToAvoidBottomInset:
          false, //used to ovoid bottomoverflow, but now button does not move above keyboard anymore at all
      backgroundColor: Colors.black, //Colors.deepPurple.withOpacity(0.4),
      appBar: AppBar(
        backgroundColor: Colors.black, //Colors.deepPurple.withOpacity(0),
        elevation: 0,
        title: Text("Create event"),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
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
                    formData['eventName'] = value;
                  });
                },
              ),
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
              child: TextFormField(
                maxLines: null,
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
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(50),
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  side: BorderSide(color: Colors.white),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(Icons.privacy_tip_outlined, color: Colors.greenAccent),
                    Align(
                      alignment: Alignment.center,
                      child: Text("Is event private",
                          style: TextStyle(color: Colors.white)),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Switch(
                        activeColor: Colors.greenAccent,
                        inactiveTrackColor: Colors.white,
                        value: isPrivate,
                        onChanged: (value) {
                          setState(() {
                            isPrivate = value;
                            formData["isPrivate"] = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
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
            SizedBox(height: 15),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                          primary: Colors.black, // Colors.white.withOpacity(0),
                          side: BorderSide(color: Colors.white, width: 1)),
                      onPressed: () {
                        _handleImageSelection();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.add_a_photo_outlined,
                                color: Colors.greenAccent),
                            SizedBox(width: 10),
                            Flexible(
                              child: AutoSizeText('UPLOAD EVENT PICTURE',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(60)),
                    child: CircleAvatar(
                        backgroundColor: Colors.black,
                        backgroundImage: NetworkImage(formData["eventPicture"]),
                        radius: 55),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
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
                  setState(() {
                    formData["location"] = GeoPoint(
                        applicationBloc.approvedLocation.latitude,
                        applicationBloc.approvedLocation.longitude);
                    formData["hostingGroup"] = {
                      "groupId": widget.group.id,
                      "groupName": widget.group.groupName,
                      "groupPicture": widget.group.groupPicture
                    };
                  });
                  print('Submitting form');
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save(); //onSaved is called!
                    addEventBatch();
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
