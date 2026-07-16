import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String currentLanguage = "Deutsch";
String? currentState;
// bool isLightMode = false;
bool showAds = true;
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

// Translate to any language
Future<String> translate(String text) async {
  const apiKey = 'S9RVZNv17VZi1CiBQZrZcK';

  try {
    final response = await http.post(
      Uri.parse('https://api.langbly.com/language/translate/v2'),
      headers: {'Content-Type': 'application/json', 'X-API-Key': apiKey},
      body: jsonEncode({'q': text, 'target': _getTargetLangugage()}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return data['data']['translations'][0]['translatedText'] ?? text;
    } else {
      if (kDebugMode) {
        print('Error: ${response.statusCode}');
        print(response.body);
      }

      return text;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Translation error: $e');
    }
    return text;
  }
}

// Text direction
TextDirection getTextDirectionOnLang() {
  if (currentLanguage == "Arabisch") {
    return TextDirection.rtl;
  }
  return TextDirection.ltr;
}

// Get the code of the current Language
String _getTargetLangugage() {
  if (currentLanguage == "Arabisch") {
    return "ar";
  } else if (currentLanguage == "Deutsch") {
    return "de";
  } else if (currentLanguage == "Französisch") {
    return "de";
  } else if (currentLanguage == "Italienisch") {
    return "de";
  } else if (currentLanguage == "Polnisch") {
    return "de";
  } else if (currentLanguage == "Russisch") {
    return "de";
  } else if (currentLanguage == "Spanisch") {
    return "de";
  } else if (currentLanguage == "Türkisch") {
    return "de";
  } else if (currentLanguage == "Ukrainisch") {
    return "de";
  }

  return "en";
}
