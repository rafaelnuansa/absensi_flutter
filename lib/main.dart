// import 'package:absensi/firebase_api.dart';
import 'package:absensi/providers/leave_filter_provider.dart';
import 'package:absensi/providers/leave_provider.dart';
import 'package:absensi/providers/patrol_photos_provider.dart';
import 'package:absensi/providers/presence_filter_provider.dart';
import 'package:absensi/screens/main_screen.dart';
import 'package:absensi/screens/splash_screen.dart';
import 'package:absensi/utils/shared.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // await FirebaseApi().initNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => PatrolPhotosProvider()),
        ChangeNotifierProvider(create: (_) => LeaveFilterProvider()),
        ChangeNotifierProvider(create: (_) => PresenceFilterProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPrefsUtil.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            theme: ThemeData(
              textTheme: GoogleFonts.interTextTheme().copyWith(
                bodyLarge: GoogleFonts.inter().copyWith(fontSize: 14),
                bodyMedium: GoogleFonts.inter().copyWith(fontSize: 12),
                bodySmall: GoogleFonts.inter().copyWith(fontSize: 10),
              ),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
            routes: {
              '/dashboard': (context) => const MainScreen(
                    selectedIndex: 0,
                  ),
            },
            debugShowCheckedModeBanner: false,
          );
        } else {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }
      },
    );
  }
}
