import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

String dummyLoggedUser = "";

class UserBalancesProvider extends ChangeNotifier {
  int vCredits = 0;
  double vEarnings = 0.0;
  int credits = 0;
  double earnings = 0.0;
  String currency = "USD";
  bool loading = false;

  Future<void> loadBalances({String? userUuid, bool resetVCredits = true}) async {
    loading = true;
    notifyListeners();

    final String uid = userUuid ?? dummyLoggedUser;

    final creditsSnap  = await FirebaseDatabase.instance.ref('credits/$uid').get();
    final earningsSnap = await FirebaseDatabase.instance.ref('earnings/$uid').get();
    final currencySnap = await FirebaseDatabase.instance.ref('users/$uid/currency').get();

    credits  = (creditsSnap.exists  && creditsSnap.value  != null)
        ? int.tryParse(creditsSnap.value.toString()) ?? 0
        : 0;
    earnings = (earningsSnap.exists && earningsSnap.value != null)
        ? double.tryParse(earningsSnap.value.toString()) ?? 0.0
        : 0.0;
    currency = (currencySnap.exists && currencySnap.value != null)
        ? currencySnap.value.toString()
        : "USD";

    if (resetVCredits) {
      vCredits  = credits;
      vEarnings = earnings;
    }

    loading = false;
    notifyListeners();
  }

  int get getCredits   => credits;
  double get getEarnings => earnings;
  int get getVCredits  => vCredits;
  double get getVEarnings => vEarnings;
  String get getCurrency => currency;

  void subtractFromCredits({int? amount}) {
    if (amount != null) {
      vCredits -= amount;
      notifyListeners();
    }
  }

  void addToCredits({int? amount}) {
    if (amount != null) {
      vCredits += amount;
      notifyListeners();
    }
  }

  void subtractFromEarnings({int? amount}) {
    if (amount != null) {
      vEarnings -= amount;
      notifyListeners();
    }
  }

  void addToEarnings({int? amount}) {
    if (amount != null) {
      vEarnings += amount;
      notifyListeners();
    }
  }
}

final userBalancesProvider = UserBalancesProvider();
List<Map<String, dynamic>> userActions = [];
