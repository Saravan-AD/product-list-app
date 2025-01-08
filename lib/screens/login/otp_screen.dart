import 'package:flutter/material.dart';
import 'package:product_listing_app/main.dart';

import 'register_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String otp;
  final bool userExists;

  OtpScreen({required this.phoneNumber, required this.otp, required this.userExists});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> validateOtp() async {
    final enteredOtp = _otpController.text.trim();

    if (enteredOtp != widget.otp) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid OTP")));
      return;
    }

    if (widget.userExists) {
      // User exists, proceed to home
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Login Successful")));
      Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => MainScreen()),
  (route) => false, // This removes all previous routes
);
    } else {
      // User doesn't exist, prompt for name
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterScreen(phoneNumber: widget.phoneNumber),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Enter the OTP sent to your phone'),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'OTP'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: validateOtp,
                    child: Text('Submit'),
                  ),
          ],
        ),
      ),
    );
  }
}
