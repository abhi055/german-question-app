import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:google_fonts/google_fonts.dart';
import 'package:question_app/data/data.dart';
import 'package:question_app/data/models/question_translated.dart';
import 'package:question_app/data/models/question_german.dart';
import 'package:question_app/data/models/state_data.dart';
import 'package:question_app/data/sources/local/json_loader.dart';
import 'package:question_app/database/saved_db_data.dart';
import 'package:question_app/database/shared_pref.dart';
import 'package:question_app/widgets/ad/ad_helper.dart';
import 'package:question_app/widgets/ad/banner_ad_widget.dart';
import 'package:question_app/widgets/display_snackbar.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class QuestionsScreen extends StatefulWidget {
  final String title;
  final List<QuestionGerman> questions;
  const QuestionsScreen({
    super.key,
    required this.title,
    required this.questions,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final Color wrongAnswerColor = Colors.red;
  final Color correctAnswerColor = Colors.green;
  String? hoveredOption;
  int questionNo = 0;
  String chosenAnswer = " ";
  bool isTranslated = false;
  bool isStatesQuestion = false;
  List<QuestionTranslated>? translatedQuestions;
  bool hasImage = false;
  bool isTranslating = false;
  List<int> savedQuestionsIndex = [];
  List<Map<String, dynamic>> analysedQuestions = [];
  final ItemScrollController _itemScrollController = ItemScrollController();
  int noOfQuestionsTaken = 0;

  @override
  void initState() {
    super.initState();
    getLastQuestionIndex();
    checkIfState();
    getTranslatedQuestions();
    getSavedQuestions();
    getAnalysedQuestions();
  }

  int _clampQuestionIndex(int index) {
    if (widget.questions.isEmpty) return 0;
    return index.clamp(0, widget.questions.length - 1);
  }

  // Get saved last question index
  void getLastQuestionIndex() async {
    if (widget.title == "Markierte Fragen") return;
    if (widget.questions.isEmpty) return;

    final savedIndex = await getInt(
      key: "${widget.title}-question-index",
      defaultValue: 0,
    );
    questionNo = _clampQuestionIndex(savedIndex);

    if (savedIndex != questionNo) {
      await setInt(key: "${widget.title}-question-index", value: questionNo);
    }

    if (mounted) setState(() {});
    await updateHasImage();
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

  // Check if the title state
  void checkIfState() async {
    if (!widget.title.contains("Fragen")) return;

    List<StateData> states = await JsonLoader.loadStates();
    for (var entry in states) {
      if (entry.text ==
          widget.title.substring(0, widget.title.indexOf("Fragen"))) {
        isStatesQuestion = true;
        return;
      }
    }
  }

  // save the last question index
  Future<void> saveQuestionIndexSPref() async {
    if (widget.title == "Markierte Fragen" || widget.questions.isEmpty) return;
    await setInt(
      key: "${widget.title}-question-index",
      value: _clampQuestionIndex(questionNo),
    );
  }

  // Get translated questions
  Future<void> getTranslatedQuestions() async {
    translatedQuestions = await JsonLoader.loadTranslatedQuestions();

    if (mounted) {
      setState(() {});
    }
  }

  // Update if question has image
  Future<void> updateHasImage() async {
    hasImage = await doesImageExist();
    if (mounted) {
      setState(() {});
    }
  }

  // Show model sheet from humberger icon
  void showModalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      builder: (context) {
        Future.delayed(Duration(milliseconds: 100), () {
          _itemScrollController.scrollTo(
            index: questionNo,
            duration: Duration(milliseconds: 400),
          );
        });
        return DraggableScrollableSheet(
          initialChildSize: 0.6, // 👈 starts at 60%
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) => Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ScrollablePositionedList.builder(
              itemScrollController: _itemScrollController,
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                QuestionGerman question = widget.questions[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text
                      if (index == 0)
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "GEHE ZU AUFGABE NR.",
                            overflow: TextOverflow.visible,
                            maxLines: 4,
                            style: GoogleFonts.poppins(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      // Choose question
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            questionNo = index;
                            hasImage = false;
                          });
                          await saveQuestionIndexSPref();
                          await updateHasImage();
                          if (context.mounted) Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: index != questionNo
                                ? Theme.of(context).cardTheme.color
                                : Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Question Number
                                Text(
                                  "${index + 1}.",
                                  style: GoogleFonts.poppins(
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // Question
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 27.0,
                                    ),
                                    child: Text(
                                      question.question,
                                      overflow: TextOverflow.visible,
                                      maxLines: 4,
                                      style: GoogleFonts.poppins(
                                        color: index == questionNo
                                            ? Colors.white
                                            : Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),

                                // Go to the question
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: index == questionNo
                                      ? Colors.white
                                      : Theme.of(context).iconTheme.color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
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

  // Get analysis of the questions
  Future<void> getAnalysedQuestions() async {
    analysedQuestions = await SavedDbData().getAllAnalysedQuestions();
    setState(() {});
  }

  // Edit question count after use choose the answer
  Future<void> editAnalysedQuestions(bool isTrue) async {
    await SavedDbData().upsertAnalysedQuestion(
      index: widget.questions[questionNo].index,
      isTrue: isTrue,
    );
  }

  // Get analysis of the current question
  Map<String, dynamic>? getCurrentQuestionAnalysis() {
    Map<String, dynamic>? currentAnalysis;

    try {
      currentAnalysis = analysedQuestions.firstWhere(
        (e) => e['question_index'] == widget.questions[questionNo].index,
      );

      return currentAnalysis;
    } catch (e) {
      currentAnalysis = null;
    }
    return currentAnalysis;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Bottom buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Banner Ad
          const BannerAdWidget(),

          // Bottom Buttons
          Container(
            height: 70,
            color: const Color.fromARGB(255, 101, 39, 176),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // previous question button
                  InkWell(
                    onTap: () async {
                      if (questionNo != 0) {
                        setState(() {
                          noOfQuestionsTaken++;
                          questionNo--;
                          hasImage = false;
                          chosenAnswer = " ";
                        });
                        if (noOfQuestionsTaken == 20) {
                          AdHelper.showInterstitialIfReady();
                          noOfQuestionsTaken = 0;
                        }
                        hasImage = await doesImageExist();
                        await saveQuestionIndexSPref();
                        await updateHasImage();
                      } else {
                        displaySnackBar(
                          text: "First Question",
                          context: context,
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 18,
                        ),
                        const Text(
                          "Vorherige",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  // middle button All Questions
                  IconButton(
                    onPressed: () => showModalSheet(),
                    icon: const Icon(Icons.list, color: Colors.white, size: 25),
                  ),

                  // next question button
                  GestureDetector(
                    onTap: () async {
                      if (questionNo != widget.questions.length - 1) {
                        setState(() {
                          noOfQuestionsTaken++;
                          questionNo++;
                          hasImage = false;
                          chosenAnswer = " ";
                        });
                        if (noOfQuestionsTaken == 20) {
                          AdHelper.showInterstitialIfReady();
                          noOfQuestionsTaken = 0;
                        }
                        hasImage = await doesImageExist();
                        await saveQuestionIndexSPref();
                        await updateHasImage();
                      } else {
                        displaySnackBar(
                          text: "Last Question",
                          context: context,
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Nächste",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),

                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // App Bar
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 80 : 70,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                    // Return to home screen button
                    leading: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).iconTheme.color,
                        size: 20,
                      ),
                    ),
                    // Aufgabe text
                    title: Text(
                      "Aufgabe ${widget.questions[questionNo].index + 1}",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 10 : 16,
                      ),
                    ),
                    // State text
                    subtitle: Text(
                      widget.questions[questionNo].category,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                        fontSize: isSmallScreen ? 8 : 12,
                      ),
                    ),
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Translation Button
                        if (currentLanguage != "Deutsch")
                          IconButton(
                            onPressed: () async {
                              if (isTranslating) return;
                              setState(() {
                                isTranslating = true;
                              });
                              if (isTranslated) {
                                isTranslated = false;
                              } else {
                                await updateHasImage();
                                isTranslated = true;
                              }

                              setState(() {
                                isTranslating = false;
                              });
                            },
                            icon: Icon(
                              isTranslating
                                  ? Icons.timer
                                  : Icons.translate_outlined,
                              color: isTranslated
                                  ? Colors.orange
                                  : Theme.of(context).iconTheme.color,
                            ),
                          ),

                        // Analysis
                        IconButton(
                          onPressed: () async {
                            await getAnalysedQuestions();
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  // Show false and true count for question
                                  return Dialog(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(3),
                                        border: Border.all(
                                          color: Colors.white38,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Question number
                                            Text(
                                              "Aufgabe ${widget.questions[questionNo].index + 1}",
                                              textAlign: TextAlign.start,
                                              style: GoogleFonts.poppins(
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.titleLarge?.color,
                                                fontSize: 23,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            Divider(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.color,
                                              thickness: 1.4,
                                            ),

                                            // False answers
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // False answers text
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    "Anzahl der Male falsch beantwortet",
                                                    textAlign: TextAlign.start,
                                                    style: GoogleFonts.poppins(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.color,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),

                                                // False answers count
                                                Expanded(
                                                  child: Text(
                                                    getCurrentQuestionAnalysis()?['incorrect_count']
                                                            .toString() ??
                                                        "0",
                                                    textAlign: TextAlign.end,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: GoogleFonts.poppins(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.color,
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            Divider(
                                              color: Theme.of(
                                                context,
                                              ).textTheme.titleLarge?.color,
                                              thickness: 1.4,
                                            ),

                                            // True answers
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                // True answers text
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                    "Anzahl der Male richtig beantwortet",
                                                    textAlign: TextAlign.start,
                                                    style: GoogleFonts.poppins(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.color,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),

                                                // True answers count
                                                Expanded(
                                                  child: Text(
                                                    getCurrentQuestionAnalysis()?['correct_count']
                                                            .toString() ??
                                                        "0",
                                                    textAlign: TextAlign.end,
                                                    style: GoogleFonts.poppins(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.color,
                                                      fontSize: 19,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
                          },
                          icon: Icon(
                            Icons.analytics_outlined,
                            color: Theme.of(context).iconTheme.color,
                            size: 35,
                          ),
                        ),

                        // Star
                        IconButton(
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
                      ],
                    ),
                  ),
                ),

                // Body
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 30),

                      // Question
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // German Question
                          Text(
                            widget.questions[questionNo].question,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                              fontSize: isSmallScreen ? 16 : 20,
                            ),
                          ),

                          // Translated Question
                          if (translatedQuestions != null && isTranslated)
                            Text(
                              translatedQuestions![widget
                                      .questions[questionNo]
                                      .index]
                                  .question,
                              textDirection: getTextDirectionOnLang(),
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontSize: isSmallScreen ? 16 : 20,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Question image
                      if (hasImage)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: SizedBox(
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
                                  onTap: () async {
                                    chosenAnswer = option;
                                    if (chosenAnswer ==
                                        widget
                                            .questions[questionNo]
                                            .correctAnswer) {
                                      await editAnalysedQuestions(true);
                                    } else {
                                      HapticFeedback.vibrate();
                                      await editAnalysedQuestions(false);
                                    }
                                    setState(() {});
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
                                            ? chosenAnswer != " " &&
                                                      option ==
                                                          widget
                                                              .questions[questionNo]
                                                              .correctAnswer
                                                  ? correctAnswerColor
                                                  : Theme.of(
                                                      context,
                                                    ).cardTheme.color
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
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
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
                                                  if (translatedQuestions !=
                                                          null &&
                                                      isTranslated)
                                                    Text(
                                                      translatedQuestions![widget
                                                              .questions[questionNo]
                                                              .index]
                                                          .options[widget
                                                          .questions[questionNo]
                                                          .options
                                                          .indexOf(option)],
                                                      softWrap:
                                                          true, // Allow text to wrap
                                                      overflow: TextOverflow
                                                          .visible, // Show all text
                                                      textDirection:
                                                          getTextDirectionOnLang(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withValues(
                                                                      alpha:
                                                                          0.6,
                                                                    ),
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
