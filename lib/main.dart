import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:club_dj/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data == ConnectionState.active) {
          User? user = snapshot.data;

          if (user == null) {
            // Not logged in
            return LoginPage();
          } else {
            // Logged in
            return UserDataCheckPage(user.uid);
          }
        } else {
          // Connection state is not active yet
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _phoneNumberController;
  late TextEditingController _otpController;
  String verificationId = "";

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
    _otpController = TextEditingController();
  }

  void _verifyPhoneNumber() async {
    try {
      String phoneNumber = "+91${_phoneNumberController.text.trim()}";
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            this.verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            this.verificationId = verificationId;
          });
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      print(e);
    }
  }

  void _signInWithOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: _otpController.text.trim(),
    );

    try {
      await _auth.signInWithCredential(credential);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Function to initiate Google Sign-In
  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
      // Handle successful sign-in
    } catch (error) {
      print('Error during Google Sign-In: $error');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OTP Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleSignIn,
                child: Text('Send OTP'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'OTP'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signInWithOTP,
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserDataCheckPage extends StatelessWidget {
  final String userUid;

  UserDataCheckPage(this.userUid);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userUid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          if (snapshot.hasData && snapshot.data!.exists) {
            // User data exists
            return HomePage();
          } else {
            // User data doesn't exist
            return UserInfoCollectionPage(userUid);
          }
        }
      },
    );
  }
}

class UserInfoCollectionPage extends StatelessWidget {
  final String userUid;

  UserInfoCollectionPage(this.userUid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User Info Collection')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Collect User Info'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserInfoSubmissionPage(userUid)),
                );
              },
              child: Text('Submit User Info'),
            ),
          ],
        ),
      ),
    );
  }
}

class UserInfoSubmissionPage extends StatelessWidget {
  final String userUid;

  UserInfoSubmissionPage(this.userUid);

  @override
  Widget build(BuildContext context) {
    // Implement user info submission UI here
    return Scaffold(
      appBar: AppBar(title: Text('Submit User Info')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('User Info Submission Page'),
            // Add form fields for collecting user info
            ElevatedButton(
              onPressed: () {
                // Save user info to Firestore and navigate to home page
                // Example: saveUserDataToFirestore();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Text('Save and Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Text('Home Page'),
      ),
    );
  }
}
