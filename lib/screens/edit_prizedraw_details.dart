import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/api/api_service.dart';

class EditPrizedrawDetails extends StatefulWidget {
  final int tagId;

  EditPrizedrawDetails({required this.tagId});

  @override
  _EditPrizedrawDetailsState createState() => _EditPrizedrawDetailsState();
}

class _EditPrizedrawDetailsState extends State<EditPrizedrawDetails> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  TextEditingController companyNameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController lineIdController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController suggestionController = TextEditingController();

  String? updateAt;
  String? detailId;

  Map<String, dynamic>? userProfile;

  @override
  void initState() {
    super.initState();
    _fetchPrizeDrawDetails();
  }

  Future<void> _fetchPrizeDrawDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      // Log ค่า token
      print('Token: $token');

      // ถอดรหัส token เพื่อดึง userId
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int? userIdInt = decodedToken['userId'];

      // Log ค่า decoded token
      print('Decoded Token: $decodedToken');

      // ตรวจสอบว่าค่า userId ไม่เป็น null
      if (userIdInt != null) {
        String userId = userIdInt.toString();

        // ใช้ userId ที่ดึงได้เพื่อเรียกข้อมูลผู้ใช้จาก API
        final profile = await _apiService.getUserProfiles(userId);
        setState(() {
          userProfile = profile;
        });
      } else {
        // หากไม่มี userId ใน token ให้แสดงข้อผิดพลาด
        print('User ID not found in token');
      }
    } else {
      // หากไม่มี token ให้แสดงข้อผิดพลาด
      print('Token not found in storage');
    }

    final details = await _apiService.getPrizeDrawDetails(widget.tagId);

    print(details);
    print('userProfile' + userProfile!['username']);

    if (details != null) {
      setState(() {
        detailId = details['detail_id'].toString();
        companyNameController.text =
            details['company_name'] ?? userProfile!['username'] ?? '';
        firstNameController.text = details['first_name'] ?? '';
        lastNameController.text = details['last_name'] ?? '';
        emailController.text = details['email'] ?? '';
        phoneController.text = details['phone'] ?? '';
        lineIdController.text = details['line_id'] ?? '';
        provinceController.text = details['province'] ?? '';
        suggestionController.text = details['suggestion'] ?? '';
      });
    }
  }

  Future<void> _saveChanges() async {
    if (detailId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: Detail ID is missing')),
      );
      return;
    }

    updateAt = DateFormat('yyyy-MM-dd').format(DateTime.now());

    Map<String, String> data = {
      'company_name': companyNameController.text,
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'line_id': lineIdController.text,
      'province': provinceController.text,
      'suggestion': suggestionController.text,
      'update_at': updateAt!,
    };

    bool success = await _apiService.updatePrizeDrawDetails(detailId!, data);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกข้อมูลสำเร็จ !')),
      );

      Navigator.pushReplacementNamed(context, '/scan_history');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('บันทึกข้อมูลไม่สำเร็จ !')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ข้อมูลลงทะเบียน'),
      ),
      backgroundColor: Color(0xFFEF4D23), // ตั้งค่าสีพื้นหลังของ Scaffold
      body: SingleChildScrollView(
        // ใช้ SingleChildScrollView เพื่อให้สามารถเลื่อนหน้าได้
        child: Container(
          padding: const EdgeInsets.all(20.0),
          color: Color(0xFFEF4D23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20.0),
              Image.asset(
                'assets/images/logo-hutox-new.png',
                height: 60.0, // ปรับขนาดโลโก้ตามความเหมาะสม
              ),
              SizedBox(height: 20.0),
              SizedBox(height: 20.0),
              Text(
                'กรอกข้อมูลเพื่อรับสิทธิประโยชน์จากทางแบรนด์',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.left, // ตัวอย่างการใช้ TextAlign
              ),
              SizedBox(height: 20.0),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildTextField(Icons.business, 'คลินิก/ร้านค้า *',
                        companyNameController, true, false),
                    _buildTextField(Icons.person, 'ชื่อ *', firstNameController,
                        true, false),
                    _buildTextField(Icons.person, 'นามสกุล *',
                        lastNameController, true, false),
                    _buildTextField(Icons.phone, 'เบอร์โทรศัพท์ *',
                        phoneController, true, false),
                    _buildTextField(
                        Icons.email, 'อีเมล์', emailController, false, false),
                    _buildTextField(
                        Icons.chat, 'Line ID', lineIdController, false, false),
                    _buildTextField(Icons.location_on, 'ที่อยู่',
                        provinceController, false, false),
                    _buildTextField(Icons.comment, 'ข้อมูลเพิ่มเติม',
                        suggestionController, false, false),
                    SizedBox(height: 20.0),
                    _buildActionButton(
                      context,
                      'ลงทะเบียน',
                      Colors.red,
                      () {
                        if (_formKey.currentState!.validate()) {
                          _saveChanges();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FocusNode myFocusNode = new FocusNode();
  Widget _buildTextField(IconData icon, String label,
      TextEditingController controller, bool isRequired, bool isDisbles) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        enableInteractiveSelection: isDisbles,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          prefixIconColor: Colors.white,
          labelStyle: TextStyle(
              color: myFocusNode.hasFocus ? Colors.white : Colors.white),
          hintStyle: TextStyle(color: Colors.white),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        validator: isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกข้อมูล :$label';
                }
                return null;
              }
            : null,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFEF4D23),
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          side: BorderSide(color: Colors.white, width: 2), // เส้นขอบสีขาว
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(30),
          // ),
        ),
        onPressed: onPressed,
        child: Text(label,
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
