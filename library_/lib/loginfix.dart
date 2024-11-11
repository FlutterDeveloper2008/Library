import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/data.dart';
import 'package:bcrypt/bcrypt.dart';
import 'main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: LoginForm(),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      // Check if the username and password are 'guest'
      final String username = 'guest';
      final String password = 'guest';

      final response = await http.get(
        Uri.parse('https://dash.vips.uz/api/31/2432/35128'),
      );

      if (response.statusCode == 200) {
        List<dynamic> usersJson = json.decode(response.body);

        // Check if there is a user with the username 'guest' and matching password
        var userJson = usersJson.firstWhere(
          (user) =>
              user['username'] == username &&
              BCrypt.checkpw(password, user['password'] ?? ''),
          orElse: () => null,
        );

        if (userJson != null) {
          User user = User.fromJson(userJson);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('currentUser', json.encode(user.toJson()));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(
                onLogout: () {},
                currentUser: user,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid username or password')),
          );
        }
      } else {
        throw Exception('Failed to log in');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                onPressed: _submit,
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
      ),
    );
  }
}
