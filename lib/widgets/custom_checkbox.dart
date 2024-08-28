import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckbox({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value); // สลับสถานะเมื่อถูกคลิก
      },
      child: Container(
        width: 24.0,
        height: 24.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle, // ปรับให้เป็นวงกลม
          color: Colors.white, // สีพื้นหลัง
          border: Border.all(
            color: value
                ? Color(0xFFFF5128)
                : Colors.white, // สีขอบเมื่อถูกเลือกหรือไม่ถูกเลือก
            width: 2.0,
          ),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: 20.0,
                color: Color(0xFFFF5128), // สีเครื่องหมายถูก
              )
            : null,
      ),
    );
  }
}
