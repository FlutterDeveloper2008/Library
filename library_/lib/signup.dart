import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:library_/login.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final PageController _pageController = PageController();
  final GlobalKey<FormState> _personalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _accountInfoFormKey = GlobalKey<FormState>();

  String? _firstName;
  String? _lastName;
  String? _username;
  String? _email;
  String? _password;
  String? _confirmPassword;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  void _nextPage() {
    if (_personalInfoFormKey.currentState!.validate()) {
      _personalInfoFormKey.currentState!.save();
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _register() async {
    if (_accountInfoFormKey.currentState!.validate()) {
      _accountInfoFormKey.currentState!.save();

      if (_password != _confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }

      String hashedPassword = BCrypt.hashpw(_password!, BCrypt.gensalt());
      final String apiUrl = "https://dash.vips.uz/api-in/31/2432/35128";
      String regDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'apipassword': '1234',
            'firstname': _firstName!,
            'lastname': _lastName!,
            'username': _username!,
            'email': _email!,
            'password': hashedPassword,
            'regdate': regDate,
            'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bc/Unknown_person.jpg/694px-Unknown_person.jpg',
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful')),
          );
          Navigator.pop(context); // Navigate back to login page
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to register')),
          );
        }
      } catch (e) {
        print(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error occurred')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
              'Already have an account?',
              style: TextStyle(color: Colors.amber.shade900),
            )),
      ),
      extendBodyBehindAppBar: true,
      body: PageView(
        controller: _pageController,
        children: [
          _buildPersonalInfoPage(),
          _buildAccountInfoPage(),
        ],
      ),
    );
  }

  DateTime? _selectedDate;
  final TextEditingController _birthdateController = TextEditingController();

  Widget _buildPersonalInfoPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: ClayContainer(
          color: Colors.white,
          borderRadius: 20,
          spread: 10,
          depth: 45,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _personalInfoFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(height: 120, image: AssetImage('image/wall.png')),
                  SizedBox(height: 20),
                  Text(
                    'Personal Information',
                    style: TextStyle(
                      fontFamily: 'DancingScript',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
                  ),
                  SizedBox(height: 20),
                  // First Name Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.amber.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _firstName = value;
                    },
                  ),
                  SizedBox(height: 20),
                  // Last Name Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person),
                      filled: true,
                      fillColor: Colors.amber.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _lastName = value;
                    },
                  ),
                  SizedBox(height: 20),
                  // Birthdate Field
                  TextFormField(
                    controller: _birthdateController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Birthdate',
                      prefixIcon: Icon(Icons.calendar_today),
                      filled: true,
                      fillColor: Colors.amber.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () {
                      _selectDate(context);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your birthdate';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    ),
                    onPressed: _nextPage,
                    child: Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 280,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 200,
                child: CupertinoDatePicker(
                  initialDateTime: _selectedDate ?? DateTime(2000, 1, 1),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (DateTime dateTime) {
                    setState(() {
                      _selectedDate = dateTime;
                      _birthdateController.text =
                          DateFormat('yyyy-MM-dd').format(dateTime);
                    });
                  },
                ),
              ),
              CupertinoButton(
                child: Text('Done'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountInfoPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(35.0),
        child: ClayContainer(
          color: Colors.white,
          borderRadius: 20,
          spread: 10,
          depth: 45,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _accountInfoFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(height: 120, image: AssetImage('image/wall.png')),
                  SizedBox(height: 20),
                  Text(
                    'Account Details',
                    style: TextStyle(
                      fontFamily: 'DancingScript',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade800,
                    ),
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
                        return 'Please enter your username';
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
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.amber.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !RegExp(r"^[\w-]+@([\w-]+\.)+[a-zA-Z]{2,}$")
                              .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: obscurePassword
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
                    obscureText: obscurePassword,
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
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                        icon: obscureConfirmPassword
                            ? Icon(Icons.visibility_off)
                            : Icon(Icons.visibility),
                      ),
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.amber.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _confirmPassword = value;
                    },
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    ),
                    onPressed: _register,
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
