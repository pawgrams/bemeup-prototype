// Datei: loadonopen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../context/first_launch.dart';

class LoadOnOpenPage extends StatefulWidget {
  const LoadOnOpenPage({super.key});

  @override
  State<LoadOnOpenPage> createState() => _LoadOnOpenPageState();
}

class _LoadOnOpenPageState extends State<LoadOnOpenPage> {
  bool _redirected = false;

  @override
  void initState() {
    super.initState();
    _maybeRedirect();
  }

  Future<void> _maybeRedirect() async {
    isFirstLaunch = false;
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    if (!_redirected && mounted) {
      _redirected = true;
      Navigator.of(context).pushReplacementNamed('/start');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoAsset = isDark
        ? 'assets/logos/svg/bemeup_white.svg'
        : 'assets/logos/svg/bemeup_black.svg';
    final maxWidth = MediaQuery.of(context).size.width * 0.7;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                logoAsset,
                width: maxWidth,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                width: 48,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [Colors.white],
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
