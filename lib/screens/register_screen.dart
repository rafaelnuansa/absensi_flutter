import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:absensi/api/register_api.dart';
import 'package:absensi/models/position.dart';
import 'package:absensi/models/building.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  int? _selectedPosition; // Updated to nullable
  int? _selectedBuilding; // Updated to nullable
  File? _avatar; // Updated to nullable
  bool _isLoading = false;

  List<Position> positions = [];
  List<Building> buildings = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final List<dynamic> positionData = await RegisterAPI.fetchPositions();
    final List<dynamic> buildingData = await RegisterAPI.fetchBuildings();

    setState(() {
      positions = positionData.map((data) => Position.fromJson(data)).toList();
      buildings = buildingData.map((data) => Building.fromJson(data)).toList();
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatar = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          _avatar != null ? FileImage(_avatar!) : null,
                      child: _avatar == null
                          ? const Icon(Icons.add_a_photo,
                              size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  _buildInputField(
                    controller: _codeController,
                    labelText: 'NIK',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20.0),
                  _buildInputField(
                    controller: _nameController,
                    labelText: 'Nama Lengkap',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20.0),
                  _buildInputField(
                    controller: _emailController,
                    labelText: 'Email',
                    obscureText: false,
                  ),
                  const SizedBox(height: 20.0),
                  _buildInputField(
                    controller: _passwordController,
                    labelText: 'Password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 20.0),
                  DropdownButtonFormField<int>(
                    value: _selectedPosition,
                    onChanged: (value) {
                      setState(() {
                        _selectedPosition = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Position',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Colors.green,
                        ),
                      ),
                    ),
                    items: _buildPositionDropdownItems(),
                  ),
                  const SizedBox(height: 20.0),
                  DropdownButtonFormField<int>(
                    value: _selectedBuilding,
                    onChanged: (value) {
                      setState(() {
                        _selectedBuilding = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Building',
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: Colors.green,
                        ),
                      ),
                    ),
                    items: _buildBuildingDropdownItems(),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_avatar == null ||
                            _codeController.text.isEmpty ||
                            _nameController.text.isEmpty ||
                            _emailController.text.isEmpty ||
                            _passwordController.text.isEmpty ||
                            _selectedPosition == null ||
                            _selectedBuilding == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            // ignore: prefer_const_constructors
                            SnackBar(
                              content: const Text('Mohon lengkapi semua data'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          setState(() {
                            _isLoading = true;
                          });

                          final result = await RegisterAPI.register(
                            code: _codeController.text,
                            name: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            positionId: _selectedPosition!,
                            buildingId: _selectedBuilding!,
                            avatar: _avatar!,
                          );

                          setState(() {
                            _isLoading = false;
                          });

                          if (result['success']) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Registration Successful'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(
                                context); // Kembali ke halaman sebelumnya setelah pendaftaran berhasil
                          } else {
                            if (result['status'] == 422) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Validation Error: ${result['message']}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Registration Failed: ${result['message']}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        backgroundColor: _isLoading ? Colors.grey : Colors.blue,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Container(
                          height: 50.0,
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                )
                              : const Text(
                                  'Register',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<int>> _buildPositionDropdownItems() {
    return positions
        .map((position) => DropdownMenuItem<int>(
              value: position.id,
              child: Text(position.name),
            ))
        .toList();
  }

  List<DropdownMenuItem<int>> _buildBuildingDropdownItems() {
    return buildings
        .map((building) => DropdownMenuItem<int>(
              value: building.id,
              child: Text(building.name),
            ))
        .toList();
  }

}
