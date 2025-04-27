import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart'; // Make sure you have this file
import 'login_page.dart'; // Make sure you have this file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Check if user is logged in
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? email = prefs.getString('email');
    return username != null && email != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shared Preferences Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<bool>(
        future: checkLoginStatus(), // Checking login status
        builder: (context, snapshot) {
          // Handle loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()), // Loading
            );
          } else {
            // Check login status
            if (snapshot.data == true) {
              return HomePage(); // User is logged in, show home
            } else {
              return LoginPage(); // User is not logged in, show login
            }
          }
        },
      ),
    );
  }
}
