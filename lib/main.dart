import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:project_meetup/profile_screen.dart';
import 'package:project_meetup/sign_in_screen.dart';
import 'package:project_meetup/user_authentication.dart';
import 'package:provider/provider.dart';
import 'discover_screen.dart';
import 'profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      // ignore: avoid_print
      fetchAll().catchError((error) => print(error));
    });
  }

  Future<void> fetchAll() async {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } on PlatformException catch (e) {
      await FlutterDisplayMode.setLowRefreshRate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return const FlutterLogo();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
              providers: [
                Provider<UserAuthentication>(
                  create: (_) => UserAuthentication(FirebaseAuth.instance),
                ),
                StreamProvider(
                  create: (context) =>
                      context.read<UserAuthentication>().authStateChanges,
                  initialData: null,
                )
              ],
              child: MaterialApp(
                title: 'Meetup',
                theme: ThemeData(
                    primaryColor: Colors.lightBlue,
                    scaffoldBackgroundColor: const Color(0xFFF3F5F7),
                    colorScheme: ColorScheme.fromSwatch()
                        .copyWith(secondary: const Color(0xFFF3F5F7))),
                home: const AuthenticationWrapper(),
                debugShowCheckedModeBanner: false,
              ));
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return const FlutterLogo();
      },
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null) {
      return const BottomNavigation();
    }
    return const SignInPage();
  }
}

/// Stateful Widget for bottom navigation bar.
class BottomNavigation extends StatefulWidget {
  const BottomNavigation({Key? key}) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

/// Creating bottom navigation bar.
class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    DiscoverScreen(),
    Text(
      'Index 1: Events',
      style: optionStyle,
    ),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.stream),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.calendarDay),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.solidUser),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
