import 'package:absensi/screens/checkpoint_screen.dart';
import 'package:flutter/material.dart';
import 'package:absensi/screens/leave_screen.dart';
import 'package:absensi/screens/profile_screen.dart';
import 'package:absensi/screens/home_screen.dart';
import 'package:absensi/utils/constants.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required int selectedIndex});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<String> _appBarTitles = [
    Constants.appName,
    'Request',
    'Profile',
    'Patrol',
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    const List<Widget> screens = [
      HomeScreen(),
      LeaveScreen(),
      ProfileScreen(),
      CheckpointScreen(),
    ];
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text(
          _appBarTitles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: SizedBox(),
        ),
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.home_48_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.form_48_filled),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.person_28_regular),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.shield_48_regular),
            label: 'Patrol',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: MainScreen(
      selectedIndex: 0,
    ),
  ));
}
