import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/common_widget/on_boarding_page.dart';
import 'package:fitness/view/admin/admin_page.dart';
import 'package:fitness/view/home/home_view.dart';
import 'package:fitness/view/home/notification_view.dart';
import 'package:fitness/view/login/login_view.dart';
import 'package:fitness/view/login/signup_view.dart';
import 'package:fitness/view/login/welcome_view.dart';
import 'package:fitness/view/main_tab/main_tab_view.dart';
import 'package:fitness/view/on_boarding/on_boarding_view.dart';
import 'package:fitness/view/on_boarding/started_view.dart';
import 'package:fitness/view/photo_progress/comparison_view.dart';
import 'package:fitness/view/photo_progress/result_view.dart';
import 'package:fitness/view/profile/profile_view.dart';
import 'package:fitness/view/sleep_tracker/sleep_add_alarm_view.dart';
import 'package:fitness/view/trainer/trainer_page.dart';
import 'package:fitness/view/workout_tracker/workour_detail_view.dart';
import 'package:fitness/view/workout_tracker/workout_tracker_view.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/colo_extension.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness 3 in 1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: TColor.primaryColor1,
        fontFamily: "Poppins",
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  Future<String?> _getUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: _getUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                String? role = snapshot.data;
                if (role == 'admin') {
                  return const AdminPage();
                } else if (role == 'normal') {
                  return const MainTabView();
                }  else if (role == 'trainer') {
                  return const TrainerPage();
                } else {
                  return const LoginView();
                }
              } else {
                return const LoginView();
              }
            },
          );
        } else {
          return const StartedView();
        }
      },
    );
  }
}
