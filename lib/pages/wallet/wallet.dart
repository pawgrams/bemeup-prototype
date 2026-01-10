// Datei: pages/wallet/wallet.dart
import 'package:flutter/material.dart';
import 'package:bemeow/context/dummy_logged_user.dart';
import 'balances.dart';
import '../../widgets/popup.dart';
import 'topupbutton.dart';
import '../../widgets/elements/sectioncaption.dart';
import 'upgrade.dart';
import 'upgradebutton.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  void _openUpgradePopup(BuildContext context) {
    showPopup(
      yOffset: 0,
      useBack: false,
      child: const UpgradeWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionCaption(translationKey: 'overview'),
          Balances(userUuid: dummyLoggedUser),
          TopUpButtonsRow(
            onPressed2: () => _openUpgradePopup(context),
          ),
          const SizedBox(height: 12),
          SectionCaption(translationKey: 'plans'),
        ],
      ),
    );
  }
}

Widget walletHeaderMiddle(BuildContext context) {
  void _openUpgradePopup() {
    showPopup(
      yOffset: 0,
      useBack: false,
      child: const UpgradeWidget(),
    );
  }
  return UpgradeButton(onPressed: _openUpgradePopup);
}
