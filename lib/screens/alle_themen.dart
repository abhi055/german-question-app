import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:question_app/data/models/question_german.dart';
import 'package:question_app/functions/go_to.dart';
import 'package:question_app/screens/questions_screen.dart';
import 'package:question_app/widgets/ad/banner_ad_widget.dart';
import 'package:question_app/widgets/display_snackbar.dart';

class AlleThemen extends StatefulWidget {
  final List<QuestionGerman> allQuestions;
  const AlleThemen({super.key, required this.allQuestions});

  @override
  State<AlleThemen> createState() => _AlleThemenState();
}

class _AlleThemenState extends State<AlleThemen> {
  final Map<String, List<QuestionGerman>> _questionsByCategory = {};
  String? hoveredState;

  @override
  void initState() {
    super.initState();
    for (final question in widget.allQuestions) {
      _questionsByCategory.putIfAbsent(question.category, () => []).add(question);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;

    return Scaffold(
      floatingActionButton: const BannerAdWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              children: [
                // App Bar
                Row(
                  children: [
                    // Go back button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),

                    const SizedBox(width: 30),

                    // Alle Themen text
                    Expanded(
                      child: Text(
                        "Alle Themen",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Themen
                _questionsByCategory.isNotEmpty
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 80.0),
                          child: ListView.builder(
                            itemCount: _questionsByCategory.length,
                            itemBuilder: (context, index) {
                              final category = _questionsByCategory.keys.elementAt(
                                index,
                              );
                              final questionsCategory =
                                  _questionsByCategory[category]!;

                              return Opacity(
                                opacity: hoveredState == category ? 0.3 : 1,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: isSmallScreen ? 4.0 : 8.0,
                                  ),
                                  child: GestureDetector(
                                    onTap: () => questionsCategory.isNotEmpty
                                        ? goTo(
                                            context: context,
                                            page: QuestionsScreen(
                                              title: "Alle Themen - $category",
                                              questions: questionsCategory,
                                            ),
                                          )
                                        : displaySnackBar(
                                            text: "No questions available",
                                            context: context,
                                          ),
                                    onTapDown: (_) => setState(() {
                                      hoveredState = category;
                                    }),
                                    onTapUp: (_) => setState(() {
                                      hoveredState = null;
                                    }),
                                    onTapCancel: () => setState(() {
                                      hoveredState = null;
                                    }),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).cardTheme.color,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context).shadowColor
                                                .withValues(alpha: 0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                        border: Border(
                                          left: BorderSide(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: isSmallScreen ? 8 : 16,
                                          vertical: isSmallScreen ? 2 : 4,
                                        ),
                                        title: Text(
                                          category,
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: isSmallScreen ? 14 : 16,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'Politik in der Demokratie',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.color
                                                ?.withValues(alpha: 0.6),
                                            fontSize: isSmallScreen ? 12 : 14,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              questionsCategory.length
                                                  .toString(),
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color
                                                    ?.withValues(alpha: 0.6),
                                                fontSize: isSmallScreen
                                                    ? 14
                                                    : 16,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.chevron_right,
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color
                                                  ?.withValues(alpha: 0.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
