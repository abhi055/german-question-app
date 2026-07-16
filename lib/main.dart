import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:question_app/data/data.dart';
import 'package:question_app/data/models/state_data.dart';
import 'package:question_app/database/shared_pref.dart';
import 'package:question_app/screens/choose_state_screen.dart';
import 'package:question_app/screens/home_screen.dart';
import 'package:question_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint(e.toString());
  }
  currentState = await getStringNoDefault(key: "state");
  currentLanguage = await getString(key: "language", defaultValue: "Englisch");
  themeNotifier.value = ThemeMode.system;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          title: 'Question App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          debugShowCheckedModeBanner: false,
          home: currentState == null
              ? ChooseStateScreen(
                  chosenState: StateData(
                    text: "Baden-Württemberg",
                    image: "assets/images/states/bw.png",
                  ),
                )
              : const HomeScreen(),
        );
      },
    );
  }
}
