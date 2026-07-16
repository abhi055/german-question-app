import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:question_app/data/models/question_german.dart';
import 'package:question_app/database/saved_db_data.dart';
import 'package:question_app/database/shared_pref.dart';
import 'package:question_app/functions/go_to.dart';
import 'package:question_app/screens/questions_screen.dart';
import 'package:question_app/widgets/ad/banner_ad_widget.dart';

class AnalysisScreen extends StatefulWidget {
  final List<QuestionGerman> allQuestions;
  const AnalysisScreen({super.key, required this.allQuestions});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  List<Map<String, dynamic>>? analysedQuestions;
  String chosenMode = "Fragen";
  List<Map<int, String>> topics = [
    {0: "Fragen"},
    {1: "Testergebnisse"},
  ];
  Map<String, int> testCountResults = {};
  List<Map<String, dynamic>> testQuestionsResults = [];
  int tapedQuestionIndex = -1;

  @override
  void initState() {
    super.initState();
    getAnalysedQuestions();
    getTestCountResults();
    getCorrectAndIncorrectQuestions();
  }

  // Get analysis of the questions
  void getAnalysedQuestions() async {
    analysedQuestions = await SavedDbData().getAllAnalysedQuestions();

    setState(() {});
  }

  // Get the count of the true or false answer in a question
  String getTrueFalseCount({
    required int questionIndex,
    required bool getTrue,
  }) {
    if (analysedQuestions != null) {
      for (int i = 0; i < analysedQuestions!.length; i++) {
        if (analysedQuestions![i]['question_index'] == questionIndex) {
          return getTrue
              ? analysedQuestions![i]["correct_count"].toString()
              : analysedQuestions![i]["incorrect_count"].toString();
        }
      }
    }

    return "0";
  }

  // Get pass and fail count
  void getTestCountResults() async {
    testCountResults["Bestanden"] = await getInt(
      key: "passTestCount",
      defaultValue: 0,
    );
    testCountResults["Nicht bestanden"] = await getInt(
      key: "failTestCount",
      defaultValue: 0,
    );

    setState(() {});
  }

  // Get every test answers
  void getCorrectAndIncorrectQuestions() async {
    testQuestionsResults = await SavedDbData().getAllTestResults();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: const BannerAdWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analysis App Bar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ListTile(
                  // Return to home screen button
                  leading: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  // Aufgabe text
                  title: Text(
                    "Analyse",
                    style: TextStyle(
                      color: Theme.of(context).textTheme.titleLarge?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 20,
                    ),
                  ),
                ),
              ),

              Divider(),

              // Fragen or Testergebnisse
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < 2; i++)
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                chosenMode = topics[i][i]!;
                              }),
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: topics[i][i] == chosenMode
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    topics[i][i]!,
                                    style: GoogleFonts.poppins(
                                      color: topics[i][i] == chosenMode
                                          ? Colors.white
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 15 : 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: chosenMode == "Fragen"
                    ?
                      // Fragen
                      Column(
                        children: [
                          // True False
                          if (kDebugMode)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                left: 8.0,
                                right: 8.0,
                                bottom: 3,
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Richtig",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),

                                      const SizedBox(width: 20),

                                      Text(
                                        "Falsch",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // # Frage Richtig Falsch
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  children: [
                                    // # Frage
                                    Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Text(
                                            "#",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),

                                          const SizedBox(width: 20),

                                          Text(
                                            "Frage",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Riching Falsch
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Richtig",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),

                                          Text(
                                            "Falsch",
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Questions
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: widget.allQuestions.map((question) {
                                  return GestureDetector(
                                    onTap: () => goTo(
                                      context: context,
                                      page: QuestionsScreen(
                                        title: (question.index + 1).toString(),
                                        questions: [question],
                                      ),
                                      onPress: () => getAnalysedQuestions(),
                                    ),
                                    onTapDown: (_) => setState(() {
                                      tapedQuestionIndex = question.index;
                                    }),
                                    onTapUp: (_) => setState(() {
                                      tapedQuestionIndex = -1;
                                    }),
                                    onTapCancel: () => setState(() {
                                      tapedQuestionIndex = -1;
                                    }),
                                    child: Opacity(
                                      opacity:
                                          tapedQuestionIndex == question.index
                                          ? 0.5
                                          : 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).cardTheme.color,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // Left row
                                                Expanded(
                                                  flex: 5,
                                                  child: Row(
                                                    children: [
                                                      // index
                                                      Text(
                                                        (question.index + 1)
                                                            .toString(),
                                                        style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 15,
                                                        ),
                                                      ),

                                                      const SizedBox(width: 20),

                                                      // Question
                                                      Expanded(
                                                        child: Text(
                                                          question
                                                                      .question
                                                                      .length >
                                                                  40
                                                              ? "${question.question.substring(0, 40)}..."
                                                              : question
                                                                    .question,
                                                          style: TextStyle(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(width: 10),

                                                // Riching Falsch
                                                Expanded(
                                                  flex: 3,
                                                  child:
                                                      analysedQuestions != null
                                                      ? Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              getTrueFalseCount(
                                                                questionIndex:
                                                                    question
                                                                        .index,
                                                                getTrue: true,
                                                              ),
                                                              style: TextStyle(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyLarge
                                                                        ?.color,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 15,
                                                              ),
                                                            ),

                                                            Text(
                                                              getTrueFalseCount(
                                                                questionIndex:
                                                                    question
                                                                        .index,
                                                                getTrue: false,
                                                              ),
                                                              style: TextStyle(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .textTheme
                                                                        .bodyLarge
                                                                        ?.color,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      )
                    // Testergebnisse
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Bestanden and Nicht bestanden
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (testCountResults.isNotEmpty)
                                    for (
                                      int i = 0;
                                      i < testCountResults.length;
                                      i++
                                    )
                                      Expanded(
                                        child: Animate(
                                          effects: [
                                            const FadeEffect(),
                                            const ScaleEffect(),
                                          ],
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Container(
                                              width: double.maxFinite,
                                              height: 160,
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).cardTheme.color,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  20.0,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      testCountResults.values
                                                          .elementAt(i)
                                                          .toString(),
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color!,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 30,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 6),

                                                    Text(
                                                      testCountResults.keys
                                                          .elementAt(i)
                                                          .toString(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .color!,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: isSmallScreen
                                                            ? 14
                                                            : 18,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                ],
                              ),

                              // Pie chart
                              if (testCountResults.isNotEmpty)
                                Animate(
                                  effects: [
                                    const FadeEffect(),
                                    const ScaleEffect(),
                                  ],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 8.0,
                                    ),
                                    child: Container(
                                      width: double.maxFinite,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).cardTheme.color,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).shadowColor
                                                .withValues(alpha: 0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Diagramm des Testfortschritts
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              "Diagramm des Testfortschritts",
                                              style: TextStyle(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.titleLarge?.color,
                                                fontWeight: FontWeight.bold,
                                                fontSize: isSmallScreen
                                                    ? 15
                                                    : 18,
                                              ),
                                            ),
                                          ),

                                          // Pie Chart
                                          testCountResults["Nicht bestanden"] !=
                                                      0 ||
                                                  testCountResults["Bestanden"] !=
                                                      0
                                              ? SizedBox(
                                                  height: 300,
                                                  child: PieChart(
                                                    PieChartData(
                                                      sections: [
                                                        // Fail
                                                        PieChartSectionData(
                                                          value:
                                                              (testCountResults["Nicht bestanden"]!)
                                                                  .toDouble(),
                                                          color: Color(
                                                            0xFFE05C52,
                                                          ),
                                                          title: '',
                                                          radius: 150,
                                                        ),
                                                        // Pass
                                                        PieChartSectionData(
                                                          value:
                                                              (testCountResults["Bestanden"]!)
                                                                  .toDouble(),
                                                          color: Color(
                                                            0xFF8BC34A,
                                                          ),
                                                          title: '',
                                                          radius: 150,
                                                        ),
                                                      ],
                                                      sectionsSpace: 0,
                                                      centerSpaceRadius: 0,
                                                    ),
                                                  ),
                                                )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 40.0,
                                                      ),
                                                  child: Text(
                                                    "Noch keine Testdaten",
                                                    style: GoogleFonts.poppins(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),

                                          // Legend
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 8,
                                                      backgroundColor: Color(
                                                        0xFF8BC34A,
                                                      ),
                                                    ),

                                                    SizedBox(width: 8),

                                                    Text(
                                                      "Test bestanden",
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 8),

                                                Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 8,
                                                      backgroundColor: Color(
                                                        0xFFE05C52,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      "Test nicht bestanden",
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.color,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Neuestes Testfortschritt
                              Text(
                                "Neuestes Testfortschritt",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),

                              // Results
                              testQuestionsResults.isNotEmpty
                                  ? Animate(
                                      effects: [
                                        const ScaleEffect(),
                                        const FadeEffect(),
                                      ],
                                      child: Column(
                                        children: testQuestionsResults.asMap().entries.map((
                                          result,
                                        ) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12.0,
                                            ),
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).cardTheme.color,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .shadowColor
                                                        .withValues(
                                                          alpha: 0.05,
                                                        ),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // Test number
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        "#${result.key + 1}",
                                                        style: TextStyle(
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),

                                                    // Scores
                                                    Row(
                                                      children: [
                                                        // Correct
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "${result.value['correct_count']}",
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFF8BC34A,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Richtig",
                                                              style: TextStyle(
                                                                color:
                                                                    Color(
                                                                      0xFF8BC34A,
                                                                    ).withValues(
                                                                      alpha:
                                                                          0.8,
                                                                    ),
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          width: 30,
                                                        ),
                                                        // Incorrect
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "${result.value['incorrect_count']}",
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFFE05C52,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Falsch",
                                                              style: TextStyle(
                                                                color:
                                                                    Color(
                                                                      0xFFE05C52,
                                                                    ).withValues(
                                                                      alpha:
                                                                          0.8,
                                                                    ),
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    )
                                  : Animate(
                                      effects: [
                                        const ScaleEffect(),
                                        const FadeEffect(),
                                      ],
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 200,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.book_rounded,
                                              color: Colors.white,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Text(
                                                "Keine Testdaten gefunden.",
                                                style: GoogleFonts.poppins(
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyLarge?.color,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }
}
