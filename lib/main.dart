import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/hutox_homepage.dart';
import 'screens/scan_product_tag_screen.dart';
import 'screens/users/scan_product_screen.dart';
import 'screens/view_profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/scan_history_screen.dart';
import 'screens/prize_history_screen.dart';
import 'screens/reset_password_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart'; // import dotenv ที่นี่

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure that SharedPreferences is initialized

  await dotenv.load(fileName: ".env"); // โหลดไฟล์ .env ก่อนที่จะเริ่มแอป
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token =
      prefs.getString('token'); // ตรวจสอบ token ใน SharedPreferences

  runApp(MyApp(isLoggedIn: token != null));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HUTOX Login',
      theme: ThemeData(
        fontFamily: 'Kanit', // กำหนดฟอนต์หลักของแอป
        primarySwatch: Colors.orange,
        textTheme: TextTheme(
          displayLarge:
              TextStyle(fontFamily: 'Kanit', fontWeight: FontWeight.bold),
          titleLarge:
              TextStyle(fontFamily: 'Kanit', fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontFamily: 'Kanit'),
          bodyMedium: TextStyle(fontFamily: 'Kanit'),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => isLoggedIn ? HutoxHomePage() : HomeScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/hutox_homepage': (context) => HutoxHomePage(),
        '/users/scan_product_tag': (context) => ScanProductScreen(),
        '/scan_product_tag': (context) => ScanProductTagScreen(),
        '/view_profile': (context) => ViewProfileScreen(),
        '/scan_history': (context) => ScanHistoryScreen(),
        '/prize_history': (context) => PrizeHistoryScreen(),
        '/edit_profile': (context) => EditProfileScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
      },
    );
  }
}
