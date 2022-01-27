import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

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

  bool isPrivate = true;

  String dropdownValue = 'One';

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
            child: Column(
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
                Spacer(flex: 3),
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
