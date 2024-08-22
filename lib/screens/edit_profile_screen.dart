import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/api/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int? userIdInt = decodedToken['userId'];

      if (userIdInt != null) {
        String userId = userIdInt.toString();
        final profile = await _apiService.getUserProfiles(userId);

        if (profile != null) {
          setState(() {
            username = profile['username'];
            email = profile['email'];
            fullNameController.text = profile['fullName'] ?? '';
            phoneController.text = profile['phoneNumber'] ?? '';
            addressController.text = profile['address'] ?? '';
            countryController.text = profile['country'] ?? '';
          });
        } else {
          // Handle the case where profile is null (e.g., show an error message)
        }
      }
    }
  }

  Future<void> _saveChanges() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      int? userIdInt = decodedToken['userId'];

      if (userIdInt != null) {
        String userId = userIdInt.toString();

        Map<String, String> data = {
          'fullName': fullNameController.text,
          'phoneNumber': phoneController.text,
          'address': addressController.text,
          'country': countryController.text,
        };

        bool success = await _apiService.updateUserProfile(userId, data);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );

          // หลังจากบันทึกสำเร็จ ให้กลับไปที่หน้า ViewProfileScreen
          Navigator.pushReplacementNamed(context, '/view_profile');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      backgroundColor: Color(0xFFFF5128), // ตั้งค่าสีพื้นหลังของ Scaffold
      body: username == null || email == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildProfileItem(
                          Icons.person,
                          'Username',
                          username!,
                          enabled: false,
                        ),
                        _buildProfileItem(
                          Icons.email,
                          'Email',
                          email!,
                          enabled: false,
                        ),
                        _buildTextField(
                          Icons.card_membership,
                          'Full Name',
                          fullNameController,
                        ),
                        _buildTextField(
                          Icons.phone,
                          'Phone',
                          phoneController,
                        ),
                        _buildTextField(
                          Icons.location_on,
                          'Address',
                          addressController,
                        ),
                        _buildTextField(
                          Icons.language,
                          'Country',
                          countryController,
                        ),
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

  Widget _buildProfileItem(
    IconData icon,
    String title,
    String value, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: Icon(icon),
        ),
        initialValue: value,
        enabled: enabled,
        style: TextStyle(color: enabled ? Colors.white : Colors.grey),
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(
              icon,
            ),
            labelStyle: TextStyle(color: Colors.white),
            prefixIconColor: Colors.white),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFF5128),
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
