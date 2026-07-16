import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:google_fonts/google_fonts.dart';
import 'package:question_app/data/models/question_german.dart';
import 'package:question_app/data/sources/local/json_loader.dart';
import 'package:question_app/database/saved_db_data.dart';
import 'package:question_app/functions/display_alert_debug.dart';
import 'package:question_app/functions/go_to.dart';
import 'package:question_app/screens/result_screen.dart';
import 'package:question_app/widgets/ad/ad_helper.dart';
import 'package:question_app/widgets/ad/banner_ad_widget.dart';

class TestScreen extends StatefulWidget {
  final List<QuestionGerman> questions;
  const TestScreen({super.key, required this.questions});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final Color wrongAnswerColor = Colors.red;
  final Color correctAnswerColor = Colors.green;
  String? hoveredOption;
  int questionNo = 0;
  String? chosenAnswer;
  bool hasImage = false;
  bool isCounted = false; // For counted answers
  Map<int, bool> isAnswerTrue = {};
  List<int> savedQuestionsIndex = [];

  @override
  void initState() {
    super.initState();
    getSavedQuestions();
    updateHasImage();
  }

  // Get saved questions
  void getSavedQuestions() async {
    savedQuestionsIndex = await SavedDbData().getAllSavedQuestions();
    setState(() {});
  }

  // Save question index in the database
  void saveQuestion() async {
    await SavedDbData().upsertIndex(index: widget.questions[questionNo].index);
    setState(() {
      savedQuestionsIndex.add(widget.questions[questionNo].index);
    });
  }

  // Remove question from database
  void removeQuestion() async {
    await SavedDbData().deleteIndex(index: widget.questions[questionNo].index);
    setState(() {
      savedQuestionsIndex.remove(widget.questions[questionNo].index);
    });
  }

  // Update if question has image
  Future<void> updateHasImage() async {
    hasImage = await doesImageExist();
    if (mounted) {
      setState(() {});
    }
  }

  // Check if image exist
  Future<bool> doesImageExist() async {
    if (widget.questions.isEmpty || questionNo >= widget.questions.length) {
      return false;
    }

    return JsonLoader.questionHasImage(widget.questions[questionNo].index);
  }

  // Is database has question
  bool isSaved() {
    if (savedQuestionsIndex.contains(widget.questions[questionNo].index)) {
      return true;
    }
    return false;
  }

  // Edit question count after use choose the answer
  Future<void> editAnalysedQuestions(bool isTrue) async {
    await SavedDbData().upsertAnalysedQuestion(
      index: widget.questions[questionNo].index,
      isTrue: isTrue,
    );
  }

  // Get the count of true or wrong answers
  int getCountOfTrueFalseAnswers(bool isTrue) {
    return isAnswerTrue.values.where((v) => v == isTrue).length;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;

    return Scaffold(
      // Bottom buttons
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Ad
            const BannerAdWidget(),

            // Next questions button
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                fixedSize: const WidgetStatePropertyAll(
                  Size(double.maxFinite, 60),
                ),
              ),
              onPressed: () async {
                if (questionNo != widget.questions.length - 1) {
                  setState(() {
                    questionNo++;
                    hasImage = false;
                    chosenAnswer = null;
                    isCounted = false;
                  });
                  hasImage = await doesImageExist();
                  await updateHasImage();
                } else {
                  AdHelper.showInterstitialIfReady();

                  goTo(
                    context: context,
                    page: ResultScreen(
                      title: "Test Result",
                      testQuestionsLength: widget.questions.length,
                      correctAnswersCount: getCountOfTrueFalseAnswers(true),
                      incorrectAnswersCount: getCountOfTrueFalseAnswers(false),
                    ),
                  );
                }
              },
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              children: [
                //  App Bar
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 60 : 75,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 0 : 16.0,
                    ),
                    // Return to home screen button
                    leading: IconButton(
                      onPressed: () => displayAlert4(
                        context: context,
                        titleText: "Möchten Sie den Test wirklich beenden?",
                        actionBtnText: "Ja",
                        actionBtnOnPress: () {
                          AdHelper.showInterstitialIfReady();
                          goTo(
                            context: context,
                            page: ResultScreen(
                              title: "Test Result",
                              testQuestionsLength: widget.questions.length,
                              correctAnswersCount: getCountOfTrueFalseAnswers(
                                true,
                              ),
                              incorrectAnswersCount: getCountOfTrueFalseAnswers(
                                false,
                              ),
                            ),
                          );
                        },
                        actionButtonColor: Theme.of(
                          context,
                        ).colorScheme.primary,
                      ),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),

                    // Testfrage text
                    title: Text(
                      "Testfrage ${questionNo + 1}",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 16 : 20,
                      ),
                    ),

                    // True and Wronge answers
                    subtitle: Row(
                      children: [
                        // Right answers
                        const CircleAvatar(
                          backgroundColor: Color.fromARGB(255, 46, 114, 48),
                          radius: 8,
                        ),

                        const SizedBox(width: 5),

                        // Right answer
                        Text(
                          getCountOfTrueFalseAnswers(true).toString(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 16 : 20,
                          ),
                        ),

                        const SizedBox(width: 10),

                        // False Answer
                        const CircleAvatar(
                          backgroundColor: Colors.red,
                          radius: 8,
                        ),

                        const SizedBox(width: 5),

                        // False answer
                        Text(
                          getCountOfTrueFalseAnswers(false).toString(),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 16 : 20,
                          ),
                        ),
                      ],
                    ),
                    // Star button
                    trailing: IconButton(
                      onPressed: () {
                        if (isSaved()) {
                          removeQuestion();
                        } else {
                          saveQuestion();
                        }
                      },
                      icon: Icon(
                        isSaved() ? Icons.star : Icons.star_border,
                        color: isSaved()
                            ? Colors.orange
                            : Theme.of(context).iconTheme.color,
                        size: 35,
                      ),
                    ),
                  ),
                ),

                const Divider(),

                // Question
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 30),

                      // Question
                      Text(
                        widget.questions[questionNo].question,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: isSmallScreen ? 16 : 20,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Question image
                      if (hasImage)
                        Column(
                          children: [
                            SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 1,
                                maxScale: 4,
                                boundaryMargin: EdgeInsets.all(100),
                                child: Image.asset(
                                  "assets/images/question-image/${widget.questions[questionNo].index + 1}.png",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),
                          ],
                        ),

                      // Options
                      Column(
                        children: widget.questions[questionNo].options
                            .map(
                              (option) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    String rightAnswer = widget
                                        .questions[questionNo]
                                        .correctAnswer;
                                    setState(() {
                                      chosenAnswer = option;
                                      if (chosenAnswer == rightAnswer &&
                                          !isCounted) {
                                        isAnswerTrue[questionNo + 1] = true;
                                        isCounted = true;
                                      } else if (!isCounted) {
                                        HapticFeedback.vibrate();
                                        isAnswerTrue[questionNo + 1] = false;
                                        isCounted = true;
                                      }
                                    });
                                  },
                                  onTapDown: (_) => setState(() {
                                    hoveredOption = option;
                                  }),
                                  onTapUp: (_) => setState(() {
                                    hoveredOption = null;
                                  }),
                                  onTapCancel: () => setState(() {
                                    hoveredOption = null;
                                  }),
                                  child: Opacity(
                                    opacity: hoveredOption == option ? 0.5 : 1,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: chosenAnswer != option
                                            ? Theme.of(context).cardTheme.color
                                            : chosenAnswer == option &&
                                                  chosenAnswer ==
                                                      widget
                                                          .questions[questionNo]
                                                          .correctAnswer
                                            ? correctAnswerColor
                                            : wrongAnswerColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.all(
                                          isSmallScreen ? 12.0 : 20.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Circle icon
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).iconTheme.color ??
                                                      Colors.white,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.circle,
                                                size: 10,
                                                color: chosenAnswer == option
                                                    ? const Color.fromARGB(
                                                        255,
                                                        82,
                                                        81,
                                                        81,
                                                      )
                                                    : Colors.transparent,
                                              ),
                                            ),

                                            const SizedBox(width: 16),

                                            // Option text
                                            Expanded(
                                              child: Text(
                                                option,
                                                softWrap:
                                                    true, // Allow text to wrap
                                                overflow: TextOverflow
                                                    .visible, // Show all text
                                                style: GoogleFonts.poppins(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 200),
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
