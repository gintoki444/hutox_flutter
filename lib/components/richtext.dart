import 'package:flutter/material.dart';

class RichTexts extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final double sizeFont;

  const RichTexts({
    Key? key,
    required this.label,
    required this.value,
    this.labelColor = Colors.black, // กำหนดค่าเริ่มต้นเป็นสีดำ
    this.valueColor = Colors.black, // กำหนดค่าเริ่มต้นเป็นสีดำ
    this.sizeFont = 16, // กำหนดค่าเริ่มต้น ดนืะ
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label : ',
            style: TextStyle(
              color: labelColor, // ใช้สีของ label ที่กำหนด
              fontWeight: FontWeight.normal,
              fontFamily: 'Kanit',
              fontSize: sizeFont,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor, // ใช้สีของ value ที่กำหนด
              fontWeight: FontWeight.bold,
              fontFamily: 'Kanit',
              fontSize: sizeFont,
            ),
          ),
        ],
      ),
    );
  }
}
