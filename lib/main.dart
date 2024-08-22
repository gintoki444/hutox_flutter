import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/hutox_homepage.dart';
import 'screens/scan_product_tag_screen.dart';
import 'screens/view_profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/prize_history_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    setState(() {
      _isLoggedIn = isLoggedIn ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HUTOX Login',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => _isLoggedIn ? HomeScreen() : LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/hutox_homepage': (context) => HutoxHomePage(),
        '/scan_product_tag': (context) => ScanProductTagScreen(),
        '/view_profile': (context) => ViewProfileScreen(),
        '/scan_history': (context) => ScanHistoryScreen(),
        '/prize_history': (context) => PrizeHistoryScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
      },
    );
  }
}
