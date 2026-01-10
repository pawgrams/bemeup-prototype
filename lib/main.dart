// Datei: main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'utils/js_util.dart';
import 'utils/muteconsole.dart';
import 'theme/dark.dart';
import 'theme/light.dart';
import 'theme/controller.dart';
import 'router.dart';
import 'auth/fbconfig.dart';
import 'translations/translations.dart';
import 'context/use_orientations.dart';
import 'context/timezone.dart';
import 'context/prices.dart';
import '../../context/dummy_logged_user.dart';

const bool testmode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  muteConsole();

  String timezone = 'UTC';
  if (kIsWeb) {
    await Firebase.initializeApp(options: fbconfig);
    timezone = await getBrowserTimezone();
  } else {
    await Firebase.initializeApp();
    timezone = await FlutterNativeTimezone.getLocalTimezone();
  }
  prices = await loadServicePrices();
  dummyLoggedUser = "00f9268e-705c-403e-ba6a-4b917f30b4f3";
  await userBalancesProvider.loadBalances(userUuid: dummyLoggedUser);
  validateTranslations();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TimezoneProvider>(
          create: (_) => TimezoneProvider()..setTimezone(timezone),
        ),
      ],
      child: testmode
          ? DevicePreview(
              enabled: true,
              builder: (context) => const BeMeowApp(testmode: true),
            )
          : const BeMeowApp(testmode: false),
    ),
  );
}

class BeMeowApp extends StatelessWidget {
  final bool testmode;
  const BeMeowApp({super.key, required this.testmode});

  @override
  Widget build(BuildContext context) {
    getAllowedOrientations(context).then(SystemChrome.setPreferredOrientations);
    return ValueListenableBuilder(
      valueListenable: themeController,
      builder: (context, ThemeMode mode, _) {
        return MaterialApp(
          locale: testmode ? DevicePreview.locale(context) : null,
          builder: (context, child) {
            final built = testmode ? DevicePreview.appBuilder(context, child) : (child ?? const SizedBox.shrink());
            final size = MediaQuery.of(context).size;
            final isLandscape = size.width > size.height;
            if (kIsWeb && isLandscape) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Only Portrait Mode available',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              );
            }
            return built;
          },
          useInheritedMediaQuery: testmode,
          supportedLocales: const [Locale('en'), Locale('de')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: mode,
          initialRoute: '/loadonopen',
          onGenerateRoute: (settings) {
            final builder = menuRoutes[settings.name];
            if (builder != null) {
              return PageRouteBuilder(
                settings: settings,
                pageBuilder: (context, __, ___) => builder(context),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              );
            }
            return null;
          },
        );
      },
    );
  }
}
