// Datei: utils/checkBalance.dart
import '../context/dummy_logged_user.dart';

bool hasEnoughCredits(int amount) {
  return userBalancesProvider.vCredits - amount >= 0 &&
         userBalancesProvider.credits - amount >= 0;
}

bool hasEnoughEarnings(int amount) {
  return userBalancesProvider.vEarnings - amount >= 0 &&
         userBalancesProvider.earnings - amount >= 0;
}

bool isBalanceUpdated(int amount) {
  return userBalancesProvider.vEarnings == userBalancesProvider.earnings &&
         userBalancesProvider.vCredits == userBalancesProvider.credits;
}

bool isVirtualHigher(int amount) {
  return userBalancesProvider.vEarnings > userBalancesProvider.earnings ||
         userBalancesProvider.vCredits > userBalancesProvider.credits;
}