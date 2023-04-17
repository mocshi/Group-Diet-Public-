import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'utils/firebase_user.dart';
import 'utils/google_auth.dart';
import 'view/home.dart';
import 'view/intro.dart';
import 'view/sign_in.dart';

import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  MobileAds.instance.initialize();

  Map<String, dynamic>? guser = await Authentication.initializeFirebase();
  if (guser != null) {
    var fuser = await FirebaseUser.initializeUser(user: guser);
    if (fuser != null) {
      runApp(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MainProvider(fuser)),
          ],
          child: const MaterialApp(
            localizationsDelegates: [
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('ja'),
            ],
            home: HomeScreen(),
          )));
      FlutterNativeSplash.remove();
    } else {
      runApp(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MainProvider(guser)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ja'),
            ],
            home: IntroScreen(user: guser),
          )));
      FlutterNativeSplash.remove();
    }
  } else {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MainProvider({})),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ja'),
        ],
        home: SignInScreen(),
      ),
    ));
    FlutterNativeSplash.remove();
  }
}

class MainProvider extends ChangeNotifier {
  Map<String, dynamic> myself;
  MainProvider(this.myself);
  bool isLoadFlg = false;

  void changeUser(Map<String, dynamic> newValue) {
    myself = newValue;
    notifyListeners();
  }

  void changeIsLoadFlg(bool newValue) {
    isLoadFlg = newValue;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignInScreen(),
    );
  }
}
