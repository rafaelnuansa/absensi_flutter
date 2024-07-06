import 'package:flutter/material.dart';
import 'package:absensi/api/profile_api.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ProfileEditScreenState createState() => ProfileEditScreenState();
}

class ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  String _errorMessage = '';
  bool _isPasswordWeak = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleShowCurrentPassword() {
    setState(() {
      _showCurrentPassword = !_showCurrentPassword;
    });
  }

  void _toggleShowNewPassword() {
    setState(() {
      _showNewPassword = !_showNewPassword;
    });
  }

  void _toggleShowConfirmPassword() {
    setState(() {
      _showConfirmPassword = !_showConfirmPassword;
    });
  }

  void _saveChanges() async {
    if (_isPasswordWeak) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
      });
      return;
    }

    try {
      final Map<String, dynamic> profileData = {
        'current_password': _currentPasswordController.text,
        'password': _newPasswordController.text,
        'password_confirmation': _confirmPasswordController.text,
      };

      if (_newPasswordController.text.length < 6) {
        setState(() {
          _errorMessage = 'Password must be at least 6 characters long';
        });
        return;
      }

      final response = await ProfileApi.updateProfile(profileData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      if (response['success']) {
        Navigator.pop(context); // Navigate back to the previous screen
      } else {
        setState(() {
          _errorMessage = response['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    }
  }

  void _checkPasswordStrength(String value) {
    setState(() {
      _isPasswordWeak = value.length < 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Change Password',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Current Password',
                suffixIcon: IconButton(
                  onPressed: _toggleShowCurrentPassword,
                  icon: Icon(_showCurrentPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ),
              obscureText: !_showCurrentPassword,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _newPasswordController,
              onChanged: _checkPasswordStrength,
              decoration: InputDecoration(
                labelText: 'New Password',
                suffixIcon: IconButton(
                  onPressed: _toggleShowNewPassword,
                  icon: Icon(_showNewPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ),
              obscureText: !_showNewPassword,
            ),
            if (_isPasswordWeak)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Password must be at least 6 characters long',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  onPressed: _toggleShowConfirmPassword,
                  icon: Icon(_showConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off),
                ),
              ),
              obscureText: !_showConfirmPassword,
            ),
            const SizedBox(height: 16.0),
            FilledButton(
              onPressed: _saveChanges,
              child: const Text('Save Changes'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
