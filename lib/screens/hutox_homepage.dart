import 'package:flutter/material.dart';
import 'scan_product_tag_screen.dart';
import 'view_profile_screen.dart';
import 'scan_history_screen.dart';
import 'prize_history_screen.dart';

class HutoxHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFEF4D23),
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50.0), // เพิ่มระยะห่างด้านบนสำหรับ logo
            Image.asset(
              'assets/images/logo-hutox-new.png',
              height: 70.0, // ปรับขนาดโลโก้ตามความเหมาะสม
            ),
            SizedBox(height: 30.0), // เพิ่มระยะห่างด้านบนสำหรับ logo

            SizedBox(height: 30.0), // เพิ่มระยะห่างระหว่าง logo และปุ่ม
            _buildMenuRow(
              context,
              'assets/images/menu-scan.png', // เปลี่ยนเป็น path ของรูปภาพแทน
              ScanProductTagScreen(),
              'assets/images/menu-profile.png',
              ViewProfileScreen(),
            ),
            SizedBox(height: 20.0),
            _buildMenuRow(
              context,
              'assets/images/menu-scan-history.png',
              ScanHistoryScreen(),
              'assets/images/menu-prize.png',
              PrizeHistoryScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow(
    BuildContext context,
    String imagePath1,
    Widget screen1,
    String imagePath2,
    Widget screen2,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMenuButton(context, imagePath1, screen1),
        _buildMenuButton(context, imagePath2, screen2),
      ],
    );
  }

  Widget _buildMenuButton(
      BuildContext context, String imagePath, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        width: 180, // กำหนดความกว้างเป็น 262
        height: 305, // กำหนดความสูงเป็น 444
        // decoration: BoxDecoration(
        //   borderRadius: BorderRadius.circular(10),
        //   border: Border.all(color: Colors.white, width: 2),
        // ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover, // ให้รูปภาพครอบคลุมเต็มพื้นที่ของ Container
          ),
        ),
      ),
    );
  }
}
