import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:question_app/data/data.dart';
import 'package:question_app/data/models/language.dart';
import 'package:question_app/data/models/question_translated.dart';
import 'package:question_app/data/models/question_german.dart';
import 'package:question_app/data/models/state_data.dart';

class JsonLoader {
  static Set<int>? _imageQuestionIndices;
  static String? _cachedImageQuestionsState;
  static List<QuestionGerman>? _cachedImageQuestions;

  static Future<Set<int>> _getImageQuestionIndices() async {
    if (_imageQuestionIndices != null) return _imageQuestionIndices!;

    final indices = <int>{};
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    for (final key in manifest.listAssets()) {
      const prefix = 'assets/images/question-image/';
      if (!key.startsWith(prefix) || !key.endsWith('.png')) continue;

      final fileName = key.substring(prefix.length, key.length - 4);
      final questionNumber = int.tryParse(fileName);
      if (questionNumber != null && questionNumber > 0) {
        indices.add(questionNumber - 1);
      }
    }

    _imageQuestionIndices = indices;
    return indices;
  }

  static Future<bool> questionHasImage(int questionIndex) async {
    final indices = await _getImageQuestionIndices();
    return indices.contains(questionIndex);
  }

  static void clearImageQuestionsCache() {
    _cachedImageQuestions = null;
    _cachedImageQuestionsState = null;
  }

  // Load germen questions
  static Future<List<QuestionGerman>> loadQuestionsGerman() async {
    final data = await rootBundle.loadString('assets/json/questions.json');
    final List<dynamic> jsonResult = json.decode(data);
    List<QuestionGerman> questions = [];
    int index = 0;
    for (int i = 0; i < jsonResult.length; i++) {
      try {
        final item = jsonResult[i] as Map<String, dynamic>;
        questions.add(QuestionGerman.fromJson(item, index++));
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing question at index $i: $e');
          print('Problematic data: ${jsonResult[i]}');
        }
      }
    }

    if (kDebugMode) {
      print(
        'Successfully loaded ${questions.length} out of ${jsonResult.length} questions',
      );
    }

    return questions;
  }

  // Load germen questions with specific state
  static Future<List<QuestionGerman>> getGermanQuestionsForState(
    String state,
  ) async {
    List<QuestionGerman> questions = await JsonLoader.loadQuestionsGerman();

    // Find german questions that have state
    List<QuestionGerman> withSpecificState = questions
        .where((q) => q.state != null && q.state!.contains(state))
        .toList();

    return withSpecificState;
  }

  // Load translated questions with specific state
  static Future<List<QuestionTranslated>>
  getTranslatedQuestionsForState() async {
    List<QuestionTranslated> questions =
        await JsonLoader.loadTranslatedQuestions();

    // Find questions that have state
    List<QuestionTranslated> withSpecificState = questions
        .where((q) => q.state != null && q.state == _getTranslatedState())
        .toList();

    return withSpecificState;
  }

  // Load translated questions with specific state
  static Future<QuestionTranslated?> getTranslatedQuestionForState({
    required int questionNo,
  }) async {
    List<QuestionTranslated> questions =
        await JsonLoader.getTranslatedQuestionsForState();

    if (questionNo >= 0 && questionNo <= questions.length) {
      return questions[questionNo];
    }
    return null;
  }

  // Load translated question
  static Future<List<QuestionTranslated>> loadTranslatedQuestions() async {
    try {
      final data = await rootBundle.loadString(_getCurrentLanguagePathFile());
      final Map<String, dynamic> jsonResult = json.decode(data);

      List<QuestionTranslated> questions = [];

      // Safer and cleaner way: loop from 1 to 460
      for (int i = 1; i <= 460; i++) {
        final key = i.toString();

        if (jsonResult.containsKey(key)) {
          try {
            final question = QuestionTranslated.fromJson(jsonResult[key]);
            questions.add(question);
          } catch (e) {
            if (kDebugMode) {
              print("Error parsing question $key: $e");
            }
          }
        } else {
          if (kDebugMode) {
            print("Warning: Question $key is missing in JSON");
          }
        }
      }

      if (kDebugMode) {
        print("Successfully loaded ${questions.length} translated questions");
        if (questions.length != 460) {
          print("Warning: Expected 460 questions, but got ${questions.length}");
        }
      }

      return questions;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to load translated questions: $e");
      }
      return [];
    }
  }

  // Get specific question
  static Future<QuestionTranslated?> getTranslatedQuestion(int index) async {
    List<QuestionTranslated> questions = await loadTranslatedQuestions();

    if (index >= 0 && index <= questions.length) {
      return questions[index];
    }
    return null;
  }

  // Load all states
  static Future<List<StateData>> loadStates() async {
    final data = await rootBundle.loadString('assets/json/state.json');
    final List jsonResult = json.decode(data);
    if (kDebugMode) {
      print("No. of Images = ${jsonResult.length}");
    }
    return jsonResult.map((e) => StateData.fromJson(e)).toList();
  }

  // Load one state
  static Future<StateData?> getState({required String text}) async {
    final List<StateData> data = await loadStates();

    for (int i = 0; i < data.length; i++) {
      if (data[i].text == text) {
        return data[i];
      }
    }

    return null;
  }

  // Load languages
  static Future<List<Language>> loadLanguages() async {
    final data = await rootBundle.loadString("assets/json/languages.json");
    List<dynamic> languages = json.decode(data);

    return languages.map((json) => Language.fromJson(json)).toList();
  }

  // Load one language
  static Future<Language?> getLanguage({required String text}) async {
    final List<Language> data = await loadLanguages();

    for (int i = 0; i < data.length; i++) {
      if (data[i].text == text) {
        return data[i];
      }
    }

    return null;
  }

  // Load questions that has image
  static Future<List<QuestionGerman>> loadImagesQuestions() async {
    if (_cachedImageQuestions != null &&
        _cachedImageQuestionsState == currentState) {
      return _cachedImageQuestions!;
    }

    final imageIndices = await _getImageQuestionIndices();
    final allQuestions = await loadQuestionsGerman();

    final questions = allQuestions.where((question) {
      if (!imageIndices.contains(question.index)) return false;
      if (currentState == null) return true;
      return question.state == null || question.state!.contains(currentState!);
    }).toList();

    _cachedImageQuestionsState = currentState;
    _cachedImageQuestions = questions;
    return questions;
  }

  // Get path of the current language data
  static String _getCurrentLanguagePathFile() {
    if (currentLanguage == "Arabisch") {
      return 'assets/json/que_ar.json';
    } else if (currentLanguage == "Deutsch") {
      return 'assets/json/questions.json';
    } else if (currentLanguage == "Französisch") {
      return 'assets/json/que_fr.json';
    } else if (currentLanguage == "Italienisch") {
      return 'assets/json/que_it.json';
    } else if (currentLanguage == "Polnisch") {
      return 'assets/json/que_pl.json';
    } else if (currentLanguage == "Russisch") {
      return 'assets/json/que_ru.json';
    } else if (currentLanguage == "Spanisch") {
      return 'assets/json/que_es.json';
    } else if (currentLanguage == "Türkisch") {
      return 'assets/json/que_tr.json';
    } else if (currentLanguage == "Ukrainisch") {
      return 'assets/json/que_uk.json';
    }

    return 'assets/json/que_en.json';
  }

  // Get translated state for current state
  static String _getTranslatedState() {
    switch (currentState) {
      case "Baden-Württemberg":
        switch (currentLanguage) {
          case "Arabisch":
            return "بادن-فورتمبيرغ";
          case "Französisch":
            return "Bade-Wurtemberg";
          case "Italienisch":
            return "Baden-Württemberg";
          case "Polnisch":
            return "Badenia-Wirtembergia";
          case "Russisch":
            return "Баден-Вюртемберг";
          case "Spanisch":
            return "Baden-Wurtemberg";
          case "Turkisch":
            return "Baden-Württemberg";
          case "Ukrainisch":
            return "Баден-Вюртемберг";
          default:
            return "Baden-Württemberg";
        }

      case "Bayern":
        switch (currentLanguage) {
          case "Arabisch":
            return "ولاية باڤاريا الحرة";
          case "Französisch":
            return "Bavière";
          case "Italienisch":
            return "Baviera";
          case "Polnisch":
            return "Bawaria";
          case "Russisch":
            return "Бавария";
          case "Spanisch":
            return "Baviera";
          case "Turkisch":
            return "Bavyera";
          case "Ukrainisch":
            return "Баварія";
          default:
            return "Free State of Bavaria";
        }

      case "Berlin":
        switch (currentLanguage) {
          case "Arabisch":
            return "برلين";
          case "Französisch":
            return "Berlin";
          case "Italienisch":
            return "Berlino";
          case "Polnisch":
            return "Berlin";
          case "Russisch":
            return "Берлин";
          case "Spanisch":
            return "Berlín";
          case "Turkisch":
            return "Berlin";
          case "Ukrainisch":
            return "Берлін";
          default:
            return "Berlin";
        }

      case "Brandenburg":
        switch (currentLanguage) {
          case "Arabisch":
            return "براندنبورغ";
          case "Französisch":
            return "Brandebourg";
          case "Italienisch":
            return "Brandeburgo";
          case "Polnisch":
            return "Brandenburgia";
          case "Russisch":
            return "Бранденбург";
          case "Spanisch":
            return "Brandeburgo";
          case "Turkisch":
            return "Brandenburg";
          case "Ukrainisch":
            return "Бранденбург";
          default:
            return "Brandenburg";
        }

      case "Freie Hansestadt Bremen":
        switch (currentLanguage) {
          case "Arabisch":
            return "مدينة بريمن الحرة الهانزية";
          case "Französisch":
            return "Ville libre hanséatique de Brême";
          case "Italienisch":
            return "Città libera anseatica di Brema";
          case "Polnisch":
            return "Wolne Miasto Hanzeatyckie Brema";
          case "Russisch":
            return "Вольный ганзейский город Бремен";
          case "Spanisch":
            return "Ciudad Libre Hanseática de Bremen";
          case "Turkisch":
            return "Hür Hansa Şehri Bremen";
          case "Ukrainisch":
            return "Вільне ганзейське місто Бремен";
          default:
            return "Free Hanseatic City of Bremen";
        }

      case "Freie und Hansestadt Hamburg":
        switch (currentLanguage) {
          case "Arabisch":
            return "مدينة هامبورغ الحرة الهانزية";
          case "Französisch":
            return "Ville libre et hanséatique de Hambourg";
          case "Italienisch":
            return "Città libera e anseatica di Amburgo";
          case "Polnisch":
            return "Wolne i Hanzeatyckie Miasto Hamburg";
          case "Russisch":
            return "Вольный и ганзейский город Гамбург";
          case "Spanisch":
            return "Ciudad Libre y Hanseática de Hamburgo";
          case "Turkisch":
            return "Hür ve Hansa Şehri Hamburg";
          case "Ukrainisch":
            return "Вільне і ганзейське місто Гамбург";
          default:
            return "Free and Hanseatic City of Hamburg";
        }

      case "Hessen":
        switch (currentLanguage) {
          case "Arabisch":
            return "هيسن";
          case "Französisch":
            return "Hesse";
          case "Italienisch":
            return "Assia";
          case "Polnisch":
            return "Hesja";
          case "Russisch":
            return "Гессен";
          case "Spanisch":
            return "Hesse";
          case "Turkisch":
            return "Hessen";
          case "Ukrainisch":
            return "Гессен";
          default:
            return "Hesse";
        }

      case "Mecklenburg-Vorpommern":
        switch (currentLanguage) {
          case "Arabisch":
            return "مكلنبورغ-فوربومرن";
          case "Französisch":
            return "Mecklembourg-Poméranie-Occidentale";
          case "Italienisch":
            return "Meclemburgo-Pomerania Anteriore";
          case "Polnisch":
            return "Meklemburgia-Pomorze Przednie";
          case "Russisch":
            return "Мекленбург-Передняя Померания";
          case "Spanisch":
            return "Mecklemburgo-Pomerania Occidental";
          case "Turkisch":
            return "Mecklenburg-Vorpommern";
          case "Ukrainisch":
            return "Мекленбург-Передня Померанія";
          default:
            return "Mecklenburg-Western Pomerania";
        }

      case "Niedersachsen":
        switch (currentLanguage) {
          case "Arabisch":
            return "ساكسونيا السفلى";
          case "Französisch":
            return "Basse-Saxe";
          case "Italienisch":
            return "Bassa Sassonia";
          case "Polnisch":
            return "Dolna Saksonia";
          case "Russisch":
            return "Нижняя Саксония";
          case "Spanisch":
            return "Baja Sajonia";
          case "Turkisch":
            return "Aşağı Saksonya";
          case "Ukrainisch":
            return "Нижня Саксонія";
          default:
            return "Lower Saxony";
        }

      case "Nordrhein-Westfalen":
        switch (currentLanguage) {
          case "Arabisch":
            return "شمال الراين-وستفاليا";
          case "Französisch":
            return "Rhénanie-du-Nord-Westphalie";
          case "Italienisch":
            return "Renania Settentrionale-Vestfalia";
          case "Polnisch":
            return "Nadrenia Północna-Westfalia";
          case "Russisch":
            return "Северный Рейн-Вестфалия";
          case "Spanisch":
            return "Renania del Norte-Westfalia";
          case "Turkisch":
            return "Kuzey Ren-Vestfalya";
          case "Ukrainisch":
            return "Північний Рейн-Вестфалія";
          default:
            return "North Rhine-Westphalia";
        }

      case "Rheinland-Pfalz":
        switch (currentLanguage) {
          case "Arabisch":
            return "راينلاند-بفالز";
          case "Französisch":
            return "Rhénanie-Palatinat";
          case "Italienisch":
            return "Renania-Palatinato";
          case "Polnisch":
            return "Nadrenia-Palatynat";
          case "Russisch":
            return "Рейнланд-Пфальц";
          case "Spanisch":
            return "Renania-Palatinado";
          case "Turkisch":
            return "Renanya-Pfalz";
          case "Ukrainisch":
            return "Рейнланд-Пфальц";
          default:
            return "Rhineland-Palatinate";
        }

      case "Saarland":
        switch (currentLanguage) {
          case "Arabisch":
            return "سارلاند";
          case "Französisch":
            return "Sarre";
          case "Italienisch":
            return "Saarland";
          case "Polnisch":
            return "Saara";
          case "Russisch":
            return "Саар";
          case "Spanisch":
            return "Sarre";
          case "Turkisch":
            return "Saarland";
          case "Ukrainisch":
            return "Саар";
          default:
            return "Saarland";
        }

      case "Freistaat Sachsen":
        switch (currentLanguage) {
          case "Arabisch":
            return "ولاية ساكسونيا الحرة";
          case "Französisch":
            return "État libre de Saxe";
          case "Italienisch":
            return "Stato libero di Sassonia";
          case "Polnisch":
            return "Wolne Państwo Saksonia";
          case "Russisch":
            return "Свободное государство Саксония";
          case "Spanisch":
            return "Estado Libre de Sajonia";
          case "Turkisch":
            return "Özgür Saksonya Devleti";
          case "Ukrainisch":
            return "Вільна держава Саксонія";
          default:
            return "Free State of Saxony";
        }

      case "Sachsen-Anhalt":
        switch (currentLanguage) {
          case "Arabisch":
            return "ساكسونيا-أنهالت";
          case "Französisch":
            return "Saxe-Anhalt";
          case "Italienisch":
            return "Sassonia-Anhalt";
          case "Polnisch":
            return "Saksonia-Anhalt";
          case "Russisch":
            return "Саксония-Анхальт";
          case "Spanisch":
            return "Sajonia-Anhalt";
          case "Turkisch":
            return "Saksonya-Anhalt";
          case "Ukrainisch":
            return "Саксонія-Ангальт";
          default:
            return "Saxony-Anhalt";
        }

      case "Schleswig-Holstein":
        switch (currentLanguage) {
          case "Arabisch":
            return "شليسفيغ-هولشتاين";
          case "Französisch":
            return "Schleswig-Holstein";
          case "Italienisch":
            return "Schleswig-Holstein";
          case "Polnisch":
            return "Szlezwik-Holsztyn";
          case "Russisch":
            return "Шлезвиг-Гольштейн";
          case "Spanisch":
            return "Schleswig-Holstein";
          case "Turkisch":
            return "Schleswig-Holstein";
          case "Ukrainisch":
            return "Шлезвіг-Гольштейн";
          default:
            return "Schleswig-Holstein";
        }

      case "Freistaat Thüringen":
        switch (currentLanguage) {
          case "Arabisch":
            return "ولاية تورينغن الحرة";
          case "Französisch":
            return "État libre de Thuringe";
          case "Italienisch":
            return "Stato libero di Turingia";
          case "Polnisch":
            return "Wolne Państwo Turyngia";
          case "Russisch":
            return "Свободное государство Тюрингия";
          case "Spanisch":
            return "Estado Libre de Turingia";
          case "Turkisch":
            return "Özgür Türingiya Devleti";
          case "Ukrainisch":
            return "Вільна держава Тюрінгія";
          default:
            return "Free State of Thuringia";
        }

      // Special entries that appear in the quiz files
      case "Federal Eagle":
        switch (currentLanguage) {
          case "Arabisch":
            return "النسر الاتحادي";
          case "Französisch":
            return "Aigle fédéral";
          case "Italienisch":
            return "Aquila federale";
          case "Polnisch":
            return "Orzeł Federalny";
          case "Russisch":
            return "Федеральный орёл";
          case "Spanisch":
            return "Águila federal";
          case "Turkisch":
            return "Federal Kartal";
          case "Ukrainisch":
            return "Федеральний орел";
          default:
            return "Federal Eagle";
        }

      case "German Democratic Republic":
        switch (currentLanguage) {
          case "Arabisch":
            return "جمهورية ألمانيا الديمقراطية";
          case "Französisch":
            return "République démocratique allemande";
          case "Italienisch":
            return "Repubblica Democratica Tedesca";
          case "Polnisch":
            return "Niemiecka Republika Demokratyczna";
          case "Russisch":
            return "Германская Демократическая Республика";
          case "Spanisch":
            return "República Democrática Alemana";
          case "Turkisch":
            return "Alman Demokratik Cumhuriyeti";
          case "Ukrainisch":
            return "Німецька Демократична Республіка";
          default:
            return "German Democratic Republic";
        }

      case "European Union (EU)":
        switch (currentLanguage) {
          case "Arabisch":
            return "الاتحاد الأوروبي";
          case "Französisch":
            return "Union européenne";
          case "Italienisch":
            return "Unione Europea";
          case "Polnisch":
            return "Unia Europejska";
          case "Russisch":
            return "Европейский Союз";
          case "Spanisch":
            return "Unión Europea";
          case "Turkisch":
            return "Avrupa Birliği";
          case "Ukrainisch":
            return "Європейський Союз";
          default:
            return "European Union (EU)";
        }
    }

    // Fallback to original state name
    return currentState!;
  }
}
