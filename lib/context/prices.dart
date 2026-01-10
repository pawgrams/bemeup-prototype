import 'package:firebase_database/firebase_database.dart';

Future<Map<String, dynamic>> loadServicePrices() async {
  final snap = await FirebaseDatabase.instance.ref('services').get();
  if (snap.exists && snap.value != null && snap.value is Map) {
    return Map<String, dynamic>.from(snap.value as Map);
  }
  return {};
}

Map<String, dynamic> prices = {};
