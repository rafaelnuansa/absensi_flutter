import 'package:absensi/screens/profile_edit_screen.dart';
import 'package:absensi/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:absensi/api/profile_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:absensi/screens/splash_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    try {
      final profile = await ProfileApi.getProfile();
      setState(() {
        _profileData = profile['profile'];
      });
    } catch (e) {
      print('Failed to load profile: $e');
    }
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('auth_token');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                );
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _profileData != null
                ? ListView(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                '${Constants.storageAvatarUrl}/${_profileData!['avatar'] ?? 'default.png'}',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: const Text(
                            'Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_profileData!['name']),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: const Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_profileData!['email']),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: const Text(
                            'Posisi/Jabatan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_profileData!['position']['name']),
                        ),
                      ),
                      Card(
                        elevation: 0,
                        child: ListTile(
                          title: const Text(
                            'Lokasi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_profileData!['building']['name']),
                        ),
                      ),
                      const SizedBox(height: 5),
                      FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileEditScreen(),
                            ),
                          );
                        },
                        child: const Text('Change Password'),
                      ),
                      const SizedBox(height: 10),
                      FilledButton(
                        onPressed: _showLogoutConfirmationDialog,
                        child: const Text('Logout'),
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
