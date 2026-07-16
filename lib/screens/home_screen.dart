import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:question_app/data/data.dart';
import 'package:question_app/data/models/question_german.dart';
import 'package:question_app/data/models/state_data.dart';
import 'package:question_app/data/sources/local/json_loader.dart';
import 'package:question_app/database/saved_db_data.dart';
import 'package:question_app/functions/go_to.dart';
import 'package:question_app/screens/alle_themen.dart';
import 'package:question_app/screens/analysis_screen.dart';
import 'package:question_app/screens/questions_screen.dart';
import 'package:question_app/screens/test_screen.dart';
import 'package:question_app/widgets/ad/ad_helper.dart';
import 'package:question_app/widgets/ad/banner_ad_widget.dart';
import 'package:question_app/widgets/display_snackbar.dart';
import 'package:question_app/widgets/home_page_drawer.dart';
import 'package:question_app/widgets/home_screen_app_bar.dart';
import 'package:question_app/widgets/topic_list_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<QuestionGerman>? allQuestions;
  List<QuestionGerman>? allQuestionsWithSpecificState;
  StateData? chosenState;
  List<QuestionGerman>? stateQuestions;
  List<int> savedQuestionsIndex = [];
  List<String> uniqueCategories = [];
  List<QuestionGerman> imagesQuestions = [];

  @override
  void initState() {
    super.initState();
    loadQuestions();
    getChosenState();
    getSavedQuestions();
    getAllImageQuestions();
    AdHelper.initNetworkListener(); // Try to get ad if wifi connected
    AdHelper.loadInterstitial(); // Load ad
  }

  // Get all questions
  void loadQuestions() async {
    allQuestions = await JsonLoader.loadQuestionsGerman();
    getAllQuestionWithSpecificState();
    for (int i = 0; i < allQuestions!.length; i++) {
      if (!uniqueCategories.contains(allQuestions![i].category)) {
        uniqueCategories.add(allQuestions![i].category);
      }
    }
    setState(() {});
  }

  // Get all questions with specifc state
  void getAllQuestionWithSpecificState() {
    allQuestionsWithSpecificState = allQuestions!.where((question) {
      return question.state == null || question.state!.contains(currentState!);
    }).toList();
    if (mounted) setState(() {});
  }

  // Get user chosen state
  void getChosenState() async {
    chosenState = await JsonLoader.getState(text: currentState!);
    stateQuestions = chosenState != null
        ? await JsonLoader.getGermanQuestionsForState(chosenState!.text)
        : null;
    if (currentState == 'Sachsen' && stateQuestions != null) {
      for (int i = 0; i < stateQuestions!.length; i++) {
        if (stateQuestions![i].category != currentState) {
          stateQuestions!.removeAt(i);
        }
      }
    }
    setState(() {});
  }

  // Get saved questions
  void getSavedQuestions() async {
    savedQuestionsIndex = await SavedDbData().getAllSavedQuestions();

    setState(() {});
  }

  // Get 33 random questions for the test
  List<QuestionGerman> getRandom33Questions() {
    final tempList = List<QuestionGerman>.from(allQuestionsWithSpecificState!);
    tempList.shuffle(Random());

    List<QuestionGerman> random33Questions = [];

    for (var question in tempList.take(33)) {
      random33Questions.add(question);
    }

    return random33Questions;
  }

  // Load images qusetions
  Future<void> getAllImageQuestions() async {
    imagesQuestions = await JsonLoader.loadImagesQuestions();
    setState(() {});
  }

  // Get categories
  void getCategories() async {
    List<QuestionGerman> trans = await JsonLoader.loadQuestionsGerman();
    int count = 0;
    for (int i = 0; i < trans.length; i++) {
      if (trans[i].state == null) {
        count++;
      }
    }
    debugPrint('Number of questions no category: $count');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: const BannerAdWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      drawer: homepageDrawer(context),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              children: [
                // App Bar
                const HomeScreenAppBar(),

                // Body
                Expanded(
                  child: ListView(
                    children: [
                      SizedBox(height: isSmallScreen ? 10 : 20),

                      allQuestions != null
                          ? Animate(
                              effects: [FadeEffect(), ScaleEffect()],
                              delay: const Duration(milliseconds: 250),
                              child: Column(
                                children: [
                                  // Alle Fragen
                                  TopicListTile(
                                    title: "Alle Fragen",
                                    iconImgPath: "assets/images/icons/book.png",
                                    questionsLength:
                                        allQuestionsWithSpecificState?.length ??
                                        0,
                                    imageColor: Theme.of(
                                      context,
                                    ).iconTheme.color,
                                    onPress: () => goTo(
                                      context: context,
                                      page: QuestionsScreen(
                                        title: "Alle Fragen",
                                        questions:
                                            allQuestionsWithSpecificState!,
                                      ),
                                      onPress: () => getSavedQuestions(),
                                    ),
                                  ),

                                  // Alle Themen
                                  if (allQuestionsWithSpecificState != null)
                                    TopicListTile(
                                      title: "Alle Themen",
                                      iconImgPath:
                                          "assets/images/icons/alle-themen.png",
                                      imageColor: Theme.of(
                                        context,
                                      ).iconTheme.color,
                                      questionsLength: uniqueCategories.length,
                                      onPress: () => goTo(
                                        context: context,
                                        page: AlleThemen(
                                          allQuestions:
                                              allQuestionsWithSpecificState!,
                                        ),
                                        onPress: () => getSavedQuestions(),
                                      ),
                                    ),

                                  // State
                                  if (chosenState != null &&
                                      stateQuestions != null)
                                    TopicListTile(
                                      title: "Bundesland Fragen",
                                      iconImgPath: chosenState!.image,
                                      questionsLength: stateQuestions!.length,
                                      onPress: () => goTo(
                                        context: context,
                                        page: QuestionsScreen(
                                          title: "${chosenState!.text} Fragen",
                                          questions: stateQuestions!,
                                        ),
                                        onPress: () => getSavedQuestions(),
                                      ),
                                    ),

                                  // Bilder Fragen
                                  if (imagesQuestions.isNotEmpty)
                                    TopicListTile(
                                      title: "Bilder Fragen",
                                      iconImgPath:
                                          "assets/images/icons/image-icon.png",
                                      imageColor: Theme.of(
                                        context,
                                      ).iconTheme.color,
                                      questionsLength: imagesQuestions.length,
                                      onPress: () => goTo(
                                        context: context,
                                        page: QuestionsScreen(
                                          title: "Bilder Fragen",
                                          questions: imagesQuestions,
                                        ),
                                      ),
                                    ),

                                  // Test Fragen
                                  TopicListTile(
                                    title: "Test Fragen",
                                    iconImgPath: "assets/images/icons/test.png",
                                    imageColor: Theme.of(
                                      context,
                                    ).iconTheme.color,
                                    questionsLength: 33,
                                    onPress: () => goTo(
                                      context: context,
                                      page: TestScreen(
                                        questions: getRandom33Questions(),
                                      ),
                                      onPress: () => getSavedQuestions(),
                                    ),
                                  ),

                                  // Analyse Fragen
                                  TopicListTile(
                                    title: "Analyse",
                                    iconImgPath:
                                        "assets/images/icons/analyse.png",
                                    imageColor: Theme.of(
                                      context,
                                    ).iconTheme.color,
                                    showQuestionsLength: false,
                                    onPress: () => goTo(
                                      context: context,
                                      page: AnalysisScreen(
                                        allQuestions: allQuestions!,
                                      ),
                                      onPress: () => getSavedQuestions(),
                                    ),
                                  ),

                                  // Saved questions
                                  TopicListTile(
                                    title: "Markierte Fragen",
                                    iconImgPath: "assets/images/icons/star.png",
                                    imageColor: Theme.of(
                                      context,
                                    ).iconTheme.color,
                                    questionsLength: allQuestions!
                                        .asMap()
                                        .entries
                                        .where(
                                          (entry) => savedQuestionsIndex
                                              .contains(entry.key),
                                        )
                                        .map((entry) => entry.value)
                                        .toList()
                                        .length,
                                    onPress: () =>
                                        allQuestions!
                                            .asMap()
                                            .entries
                                            .where(
                                              (entry) => savedQuestionsIndex
                                                  .contains(entry.key),
                                            )
                                            .map((entry) => entry.value)
                                            .toList()
                                            .isNotEmpty
                                        ? goTo(
                                            context: context,
                                            page: QuestionsScreen(
                                              title: "Markierte Fragen",
                                              questions: allQuestions!
                                                  .asMap()
                                                  .entries
                                                  .where(
                                                    (entry) =>
                                                        savedQuestionsIndex
                                                            .contains(
                                                              entry.key,
                                                            ),
                                                  )
                                                  .map((entry) => entry.value)
                                                  .toList(),
                                            ),
                                            onPress: () => getSavedQuestions(),
                                          )
                                        : displaySnackBar(
                                            text:
                                                "Du hast noch keine markierten Fragen",
                                            context: context,
                                          ),
                                  ),

                                  const SizedBox(height: 100),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
