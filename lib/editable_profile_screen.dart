import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_meetup/profile_screen.dart';
import 'package:project_meetup/sign_up_screen.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditableProfileScreen extends StatefulWidget {
  const EditableProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditableProfileScreen> createState() => _EditableProfileScreenState();
}

class _EditableProfileScreenState extends State<EditableProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController universityController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final _formKey = GlobalKey<FormState>();

// Future<void> editUser

/*
  Future<void> createUser(
      {required String email,
      required String password,
      required String firstName,
      required String lastName}) async {
    HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('createUserWithSignUp');

    final results = await callable({
      "email": email,
      "password": password,
      "firstName": firstName,
      "lastName": lastName
    });
    print(results);
  }
*/

  // Edit user profile
  Future<void> editProfileData() async {
    try {
      await users.doc(auth.currentUser!.uid).update({
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "userName": userNameController.text,
        "university": universityController.text
      });
    } on Exception catch (_) {
      print('never reached');
    }
  }

  late Size _safeAreaSize;

  bool _isLoading = false;

  void _toggleIsLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQD = MediaQuery.of(context);
    _safeAreaSize = mediaQD.size;

    return Scaffold(
      // resizeToAvoidBottomInset: false, //use this if you dont want for the keyboard to resize background image
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: ExactAssetImage('images/SignInBackground.png'),
                  fit: BoxFit.cover)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              alignment: Alignment.center,
              color: Colors.grey.withOpacity(0.1),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(top: 25, left: 10),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          )),
                    ],
                  ),
                  /*       Container(
                    alignment: Alignment.center,
                    child: Text("Welcome"),
                  ),*/
                  Spacer(flex: 2),
                  Form(
                    key: _formKey,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Hero(
                                  tag: 'tag',
                                  child: Container(
                                    height: 130,
                                    width: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(10),
                                      //  image: DecorationImage(image: ) image that the user uploads
                                    ),
                                    child: Align(
                                        alignment: Alignment.bottomRight,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.add_a_photo_outlined,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            /*let user upload photo*/
                                          },
                                        )),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    width: 210,
                                    margin: const EdgeInsets.only(bottom: 10.0),
                                    child: TextFormField(
                                      style:
                                          const TextStyle(color: Colors.white),
                                      controller: firstNameController,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(
                                            Icons.person_outline_rounded,
                                            color: Colors.white),
                                        fillColor: Colors.black54,
                                        labelText: 'First Name',
                                        labelStyle: const TextStyle(
                                            color: Colors.white54),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '*This field is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Container(
                                    width: 210,
                                    margin: const EdgeInsets.only(bottom: 10.0),
                                    child: TextFormField(
                                      style:
                                          const TextStyle(color: Colors.white),
                                      controller: lastNameController,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.person,
                                            color: Colors.white),
                                        fillColor: Colors.black54,
                                        labelText: 'Last Name',
                                        // '${data["lastName"]}',
                                        labelStyle: const TextStyle(
                                            color: Colors.white54),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never,
                                        filled: true,
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                      ),
                                      // The validator receives the text that the user has entered.
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '*This field is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: userNameController,

                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.star_border_rounded,
                                    color: Colors.white),
                                fillColor: Colors.black54,
                                labelText: 'User Name', //'${data["userName"]}',
                                labelStyle:
                                    const TextStyle(color: Colors.white54),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                                filled: true,
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '*This field is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: universityController,
                            decoration: InputDecoration(
                              fillColor: Colors.black54,
                              prefixIcon: Icon(Icons.school_outlined,
                                  color: Colors.white),
                              labelText:
                                  'University', //'${data["university"]}',
                              labelStyle:
                                  const TextStyle(color: Colors.white54),
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.never,
                              filled: true,
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            // The validator receives the text that the user has entered.
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '*This field is required';
                              }
                              return null;
                            },
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                                primary: Colors.black54,
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 35, vertical: 15),
                              ),
                              onPressed: () {
                                editProfileData();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen()));
                              },
                              child: _isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const Text("Done editing"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    /*    }
        return Text("loading");
      },
    ); */
  }
}
