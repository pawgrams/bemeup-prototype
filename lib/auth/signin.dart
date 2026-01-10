import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class SignInPage extends StatelessWidget {
  final GoogleSignIn _gs = GoogleSignIn.instance;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: Center(
          child: Text('Google-Sign-In not available yet.'),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 2,
            minimumSize: Size(220, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          icon: Image.network(
            "https://developers.google.com/identity/images/g-logo.png",
            height: 24,
            width: 24,
          ),
          label: Text(
            'Sign in with Google',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onPressed: () async {
            await _gs.authenticate();
          },
        ),
      ),
    );
  }
}
