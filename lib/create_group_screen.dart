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
        backgroundColor: const Color(0xFFF3F5F7),
        appBar: AppBar(
          title: Text("Create group"),
        ),
        body: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(
                      top: 15.0, left: 10.0, right: 10.0, bottom: 5.0),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: const TextStyle(color: Colors.black),
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
                      formData['groupName'] = value;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      top: 15.0, left: 10.0, right: 10.0, bottom: 5.0),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "Description",
                      labelStyle: const TextStyle(color: Colors.black),
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
                      formData['groupDescription'] = value;
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                      top: 15.0, left: 10.0, right: 10.0, bottom: 5.0),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Is group private"),
                      Switch(
                        value: isPrivate,
                        onChanged: (value) {
                          setState(() {
                            isPrivate = value;
                          });
                          formData["isPrivate"] = value;
                        },
                      ),
                    ],
                  ),
                ),
                /*DropdownButton<String>(
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: <String>['One', 'Two', 'Free', 'Four']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )*/
                Spacer(flex: 3),
                Container(
                  margin: EdgeInsets.only(bottom: 30.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.transparent,
                      primary: Colors.teal,
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
                    child: const Text("Create group"),
                  ),
                ),
              ],
            )));
  }
}
