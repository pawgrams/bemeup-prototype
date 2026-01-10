import 'package:firebase_auth/firebase_auth.dart';

Future<String> isLoggedGetUid() async {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid ?? '';
}


