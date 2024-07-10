import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_assignment/home_page.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;

  const OTPScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late String _otp;
  final TextEditingController _otpController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signInWithPhoneNumber(BuildContext context) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: _otp,
    );
    await _auth.signInWithCredential(credential).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verification successful')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP verification failed: ${error.toString()}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 100), // Centered Flutter logo
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              onChanged: (value) {
                setState(() {
                  _otp = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter OTP',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                filled: true,
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(color: Color(0xFFFFC629)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _signInWithPhoneNumber(context);
              },
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
