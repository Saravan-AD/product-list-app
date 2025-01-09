import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class RegisterScreen extends StatefulWidget {
  final String phoneNumber;

  RegisterScreen({required this.phoneNumber});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> registerUser() async {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Enter your name")));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('https://admin.kushinirestaurant.com/api/login-register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'first_name': name, 'phone_number': widget.phoneNumber}),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token']['access'];
      final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration Successful")));
      Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => MainScreen()),
  (route) => false, 
);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error during registration")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter your name to complete registration'),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: registerUser,
                    child: Text('Register'),
                  ),
          ],
        ),
      ),
    );
  }
}
