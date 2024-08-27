import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchPrizeDrawDetails();
  }

  Future<void> _fetchPrizeDrawDetails() async {
    final details = await _apiService.getPrizeDrawDetails(widget.tagId);
    if (details != null) {
      setState(() {
        detailId = details['detail_id'].toString();
        companyNameController.text = details['company_name'] ?? '';
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
        SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pushReplacementNamed(context, '/scan_history');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Prizedraw Details'),
      ),
      backgroundColor: Color(0xFFEF4D23), // ตั้งค่าสีพื้นหลังของ Scaffold
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildTextField(Icons.business, 'Company Name',
                      companyNameController, true),
                  _buildTextField(
                      Icons.person, 'First Name', firstNameController, true),
                  _buildTextField(
                      Icons.person, 'Last Name', lastNameController, true),
                  _buildTextField(Icons.email, 'E-mail', emailController, true),
                  _buildTextField(
                      Icons.phone, 'Phone Number', phoneController, true),
                  _buildTextField(
                      Icons.chat, 'Line ID', lineIdController, true),
                  _buildTextField(
                      Icons.location_on, 'Province', provinceController, true),
                  _buildTextField(
                      Icons.comment, 'Suggestion', suggestionController, true),
                  SizedBox(height: 20.0),
                  _buildActionButton(
                    context,
                    'Save Changes',
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
    );
  }

  FocusNode myFocusNode = new FocusNode();
  Widget _buildTextField(IconData icon, String label,
      TextEditingController controller, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
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
                  return '$label is required';
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
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
