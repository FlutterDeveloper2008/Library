import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:library_/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/data.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _username;
  String? _password;
  bool obscure = true;
  bool _isLoading = false; // Add this line

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Start loading
      });
      
      _formKey.currentState!.save();
      try {
        final response = await http.get(
          Uri.parse('https://dash.vips.uz/api/31/2432/35128'),
        );
        
        if (response.statusCode == 200) {
          List<dynamic> usersJson = json.decode(response.body);
          var userJson = usersJson.firstWhere(
            (user) =>
                user['username'] == _username &&
                BCrypt.checkpw(_password!, user['password']),
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(height: 750,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(35.0),
                child: Column(
                  children: [
                    ClayContainer(
                      color: Colors.white,
                      borderRadius: 20,
                      spread: 10,
                      depth: 45,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image(
                                  height: 120, image: AssetImage('image/wall.png')),
                              SizedBox(height: 20),
                              AnimatedTextKit(
                                animatedTexts: [
                                  TyperAnimatedText(
                                    'Welcome!',
                                    textStyle: TextStyle(
                                      fontFamily: 'DancingScript',
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade800,
                                    ),
                                    speed: Duration(milliseconds: 100),
                                  ),
                                ],
                                totalRepeatCount: 1,
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                  prefixIcon: Icon(Icons.person),
                                  filled: true,
                                  fillColor: Colors.amber.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _username = value;
                                },
                              ),
                              SizedBox(height: 20),
                              TextFormField(
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscure = !obscure;
                                      });
                                    },
                                    icon: obscure
                                        ? Icon(Icons.visibility_off)
                                        : Icon(Icons.visibility),
                                  ),
                                  labelText: 'Password',
                                  prefixIcon: Icon(Icons.lock),
                                  filled: true,
                                  fillColor: Colors.amber.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                obscureText: obscure,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _password = value;
                                },
                              ),
                              SizedBox(height: 60),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade800,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 80, vertical: 15),
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
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ),
            ),
            if (_isLoading) // Display the progress indicator when loading
              Container(
                color: Colors.black54,
                child: Align(alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    width: double.infinity,
                    height: 6,
                    child: LinearProgressIndicator(color: Colors.amber,),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' Create one',
                        style: TextStyle(color: Colors.amber.shade800),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
