import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/painting.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  CollectionReference groups = FirebaseFirestore.instance.collection('Groups');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {
    'groupName': null,
    'groupDescription': null,
    'groupPicture': "https://picsum.photos/200",
    'creator': null,
    'members': [],
    'events': [],
    'associatedInterests': {},
    'isPrivate': true,
  };

  Future<int> getUserAllowedGroups() async {
    DocumentSnapshot user = await users.doc(auth.currentUser!.uid).get();
    Map<String, dynamic> userData = user.data() as Map<String, dynamic>;
    return userData["amountCreatedGroups"];
  }

  Future<void> createGroup() async {
    try {
      int userGroupCreated = await getUserAllowedGroups();
      if (userGroupCreated >= 0 && userGroupCreated <= 3) {
        await groups.add(formData);
        await users
            .doc(auth.currentUser!.uid)
            .update({"amountCreatedGroups": userGroupCreated += 1});
      }
    } on Exception catch (_) {
      print('never reached');
    }
  }

  static List selectedInterestsList = [];

  bool isPrivate = true;

  String dropdownValue = 'One';

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
        formData["groupPicture"] = uri;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
            elevation: 0,
            title: Text("Create group"),
            backgroundColor: Colors.black),
        body: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      top: 15.0, left: 10.0, right: 10.0, bottom: 5.0),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Group Name",
                      labelStyle: const TextStyle(
                          color: Colors.white54,
                          fontSize: 16,
                          fontFamily: 'verdana_regular',
                          fontWeight: FontWeight.w400),
                      floatingLabelStyle: TextStyle(color: Colors.red[600]),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      filled: false,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(25)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE53935)),
                          borderRadius: BorderRadius.circular(25)),
                      prefixIcon: Icon(Icons.keyboard_arrow_right_rounded,
                          color: Colors.red[600]),
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
                        formData['groupName'] = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  child: TextFormField(
                    maxLines: null,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        fontFamily: 'verdana_regular',
                        fontWeight: FontWeight.w400,
                      ),
                      floatingLabelStyle: TextStyle(color: Colors.red[600]),
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      filled: false,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFE53935), width: 1.5),
                          borderRadius: BorderRadius.all(Radius.circular(25))),
                      prefixIcon:
                          Icon(Icons.textsms_outlined, color: Colors.red[600]),
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
                        formData['groupDescription'] = value;
                      });
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 5.0, horizontal: 10.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(50),
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      side: BorderSide(color: Colors.white),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Icon(Icons.privacy_tip_outlined,
                            color: Colors.red[600]),
                        Align(
                          alignment: Alignment.center,
                          child: Text("Is group private",
                              style: TextStyle(color: Colors.white)),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Switch(
                            activeColor: Colors.red[600],
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
                Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 10.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(25)),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 15, right: 15, left: 15),
                          child: Flexible(
                            child: AutoSizeText(
                                "INTERESTS associated with this group:",
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            child: Wrap(
                              spacing: 5.0,
                              runSpacing: 3.0,
                              children: <Widget>[
                                filterChipWidget(chipName: 'Music/Dance/Club'),
                                filterChipWidget(chipName: 'Sports & Fitness'),
                                filterChipWidget(chipName: 'Travel & Outdoors'),
                                filterChipWidget(chipName: 'Science & Tech'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                              primary:
                                  Colors.black, // Colors.white.withOpacity(0),
                              side: BorderSide(color: Colors.white, width: 1)),
                          onPressed: () => {_handleImageSelection()},
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.add_a_photo_outlined,
                                    color: Colors.red[600]),
                                SizedBox(width: 10),
                                Flexible(
                                  child: AutoSizeText('UPLOAD GROUP PICTURE',
                                      style: TextStyle(
                                        color: Colors.white,
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
                            backgroundImage:
                                NetworkImage(formData["groupPicture"]),
                            radius: 55),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  margin: EdgeInsets.only(bottom: 30.0, right: 10, left: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      side: BorderSide(color: Color(0xFFE53935)),
                      minimumSize: const Size.fromHeight(50),
                      primary: Colors.red[600],
                      textStyle: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 35, vertical: 15),
                    ),
                    onPressed: () {
                      print('Submitting form');
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save(); //onSaved is called!
                        createGroup();
                      }
                    },
                    child: Stack(
                      children: <Widget>[
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(Icons.publish_rounded,
                                color: Colors.black)),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "CREATE GROUP",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }
}

class filterChipWidget extends StatefulWidget {
  final String chipName;

  filterChipWidget({required this.chipName});

  @override
  _filterChipWidgetState createState() => _filterChipWidgetState();
}

class _filterChipWidgetState extends State<filterChipWidget> {
  var _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
        label: Text(widget.chipName),
        labelStyle: TextStyle(
            color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
        selected: _isSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.grey[900], //Color(0xffededed),
        onSelected: (isSelected) {
          setState(() {
            _isSelected = isSelected;
            if (_isSelected == true) {
              _CreateGroupScreenState.selectedInterestsList
                  .add(widget.chipName);
            } else if (_isSelected == false) {
              _CreateGroupScreenState.selectedInterestsList
                  .remove(widget.chipName);
            }
            print(_CreateGroupScreenState.selectedInterestsList);
          });
        },
        selectedColor: Colors.red[600] //Color(0xffeadffd),
        );
  }
}
