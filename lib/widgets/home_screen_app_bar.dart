import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:question_app/data/data.dart';
import 'package:question_app/data/models/language.dart';
import 'package:question_app/data/models/state_data.dart';
import 'package:question_app/data/sources/local/json_loader.dart';
import 'package:question_app/functions/go_to.dart';
import 'package:question_app/screens/choose_language_screen.dart';
import 'package:question_app/screens/choose_state_screen.dart';

class HomeScreenAppBar extends StatefulWidget {
  const HomeScreenAppBar({super.key});

  @override
  State<HomeScreenAppBar> createState() => _HomeScreenAppBarState();
}

class _HomeScreenAppBarState extends State<HomeScreenAppBar> {
  bool isHoveredState = false;
  bool isHoveredLanguage = false;
  StateData? chosenState;
  Language? _language;

  @override
  void initState() {
    super.initState();
    getChosenStateAndLanguage();
  }

  // Get the data of chosen state and language
  void getChosenStateAndLanguage() async {
    chosenState = await JsonLoader.getState(text: currentState!);
    _language = await JsonLoader.getLanguage(text: currentLanguage);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;

    return SizedBox(
      width: double.infinity,
      child: chosenState != null
          ? Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); // Open drawer manually
                  },
                ),
                // Choose state
                Expanded(
                  child: GestureDetector(
                    onTap: () => goTo(
                      context: context,
                      page: ChooseStateScreen(chosenState: chosenState!),
                    ),
                    onTapDown: (_) => setState(() {
                      isHoveredState = true;
                    }),
                    onTapUp: (_) => setState(() {
                      isHoveredState = false;
                    }),
                    onTapCancel: () => setState(() {
                      isHoveredState = false;
                    }),
                    child: Opacity(
                      opacity: isHoveredState ? 0.5 : 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).shadowColor.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(isSmallScreen ? 2 : 5),
                          leading: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 4.0 : 8.0),
                            child: Image.asset(
                              chosenState!.image,
                              scale: isSmallScreen ? 1.2 : 1,
                            ),
                          ),
                          title: Text(
                            "Bundesland",
                            style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.6),
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          subtitle: Text(
                            chosenState!.text,
                            style: GoogleFonts.poppins(
                              color: Theme.of(
                                context,
                              ).textTheme.titleLarge?.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Theme.of(
                              context,
                            ).iconTheme.color?.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Get Language
                _language != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: () => goTo(
                            context: context,
                            page: ChooseLanguageScreen(
                              chosenLanguage: _language!,
                            ),
                          ),
                          onTapDown: (_) => setState(() {
                            isHoveredLanguage = true;
                          }),
                          onTapUp: (_) => setState(() {
                            isHoveredLanguage = false;
                          }),
                          onTapCancel: () => setState(() {
                            isHoveredLanguage = false;
                          }),
                          child: Opacity(
                            opacity: isHoveredLanguage ? 0.5 : 1,
                            child: ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(40),
                              child: Image.asset(
                                _language!.image,
                                width: isSmallScreen ? 38 : 50,
                                height: isSmallScreen ? 38 : 50,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            )
          : null,
    );
  }
}
