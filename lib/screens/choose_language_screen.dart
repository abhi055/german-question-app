import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:question_app/data/data.dart';
import 'package:question_app/data/models/language.dart';
import 'package:question_app/data/sources/local/json_loader.dart';
import 'package:question_app/database/shared_pref.dart';
import 'package:question_app/functions/go_to.dart';
import 'package:question_app/screens/home_screen.dart';
import 'package:question_app/widgets/ad/banner_ad_widget.dart';
import 'package:question_app/widgets/selection_list_tile.dart';
import 'package:question_app/widgets/selection_screen_header.dart';

class ChooseLanguageScreen extends StatefulWidget {
  final Language chosenLanguage;
  const ChooseLanguageScreen({super.key, required this.chosenLanguage});

  @override
  State<ChooseLanguageScreen> createState() => _ChooseLanguageScreenState();
}

class _ChooseLanguageScreenState extends State<ChooseLanguageScreen> {
  List<Language>? _languages;

  @override
  void initState() {
    super.initState();
    getLanguages();
  }

  void getLanguages() async {
    _languages = await JsonLoader.loadLanguages();
    setState(() {});
  }

  Future<void> _selectLanguage(Language language) async {
    await setString(key: "language", value: language.text);
    currentLanguage = language.text;
    if (!mounted) return;
    goTo(context: context, page: const HomeScreen(), router: false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: const BannerAdWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const SelectionScreenHeader(
                title: 'Wählen Sie eine Sprache',
                subtitle:
                    'Die Fragen werden in der gewählten Sprache angezeigt.',
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _languages != null
                    ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _languages!.length,
                        itemBuilder: (context, index) {
                          final language = _languages![index];
                          final isSelected =
                              widget.chosenLanguage.text == language.text;

                          return SelectionListTile(
                            title: language.text,
                            imagePath: language.image,
                            isSelected: isSelected,
                            onTap: () => _selectLanguage(language),
                          )
                              .animate()
                              .fadeIn(
                                duration: 280.ms,
                                delay: (40 * index).ms,
                              )
                              .slideY(
                                begin: 0.08,
                                end: 0,
                                duration: 280.ms,
                                delay: (40 * index).ms,
                                curve: Curves.easeOutCubic,
                              );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(
                          color: scheme.primary,
                          strokeWidth: 2.5,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
