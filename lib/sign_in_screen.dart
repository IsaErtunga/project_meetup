import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_meetup/sign_up_screen.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
                  /*       Container(
                    alignment: Alignment.center,
                    child: Text("Welcome"),
                  ),*/
                  Spacer(flex: 3),
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
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock_outline_rounded,
                                  color: Colors.white),
                              fillColor: Colors.black54,
                              labelText: "Password",
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
                                return 'Please enter some text';
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
                                  context.read<UserAuthentication>().signIn(
                                        email: emailController.text.trim(),
                                        password:
                                            passwordController.text.trim(),
                                      );
                                }
                              },
                              child: const Text("Sign in"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(flex: 2),
                  Container(
                    margin: EdgeInsets.only(bottom: 40.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        shadowColor: Colors.transparent,
                        primary: Colors.black54,
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 15),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignUpPage()));
                      },
                      child: const Text("Sign up"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
