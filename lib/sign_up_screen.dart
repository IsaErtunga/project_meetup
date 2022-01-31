import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'sign_in_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Sign up cloud function
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

  bool _isLoading = false;

  void _toggleIsLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                          padding: EdgeInsets.only(top: 20, left: 15),
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
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: emailController,
                              decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.person_pin, color: Colors.white),
                                fillColor: Colors.black54,
                                labelText: "Email",
                                labelStyle:
                                    const TextStyle(color: Colors.white),
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
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock_outline_rounded,
                                    color: Colors.white),
                                fillColor: Colors.black54,
                                labelText: "Password",
                                labelStyle:
                                    const TextStyle(color: Colors.white),
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
                          Container(
                            margin: const EdgeInsets.only(bottom: 10.0),
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              controller: firstNameController,

                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person_outline_rounded,
                                    color: Colors.white),
                                fillColor: Colors.black54,
                                labelText: "First Name",
                                labelStyle:
                                    const TextStyle(color: Colors.white),
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
                            controller: lastNameController,

                            decoration: InputDecoration(
                              fillColor: Colors.black54,
                              prefixIcon:
                                  Icon(Icons.person, color: Colors.white),
                              labelText: "Last Name",
                              labelStyle: const TextStyle(color: Colors.white),
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
                                if (_formKey.currentState!.validate()) {
                                  _toggleIsLoading();
                                  createUser(
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                          firstName:
                                              firstNameController.text.trim(),
                                          lastName:
                                              lastNameController.text.trim())
                                      .then((value) {
                                    _toggleIsLoading(); //add navigator back to sign in screen?
                                    final snackBar = SnackBar(
                                      content: const Text(
                                          'Account created successfully!'),
                                      action: SnackBarAction(
                                        label: 'Close',
                                        onPressed: () {
                                          // Some code to undo the change.
                                        },
                                      ),
                                    );

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  });
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignInPage()));
                              },
                              child: _isLoading
                                  ? const Center(
                                      child: SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const Text("Register"),
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
  }
}
