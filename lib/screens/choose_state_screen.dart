import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:question_app/data/data.dart';
import 'package:question_app/data/models/state_data.dart';
import 'package:question_app/data/sources/local/json_loader.dart';
import 'package:question_app/database/shared_pref.dart';
import 'package:question_app/functions/go_to.dart';
import 'package:question_app/screens/home_screen.dart';
import 'package:question_app/widgets/ad/banner_ad_widget.dart';
import 'package:question_app/widgets/selection_list_tile.dart';
import 'package:question_app/widgets/selection_screen_header.dart';

class ChooseStateScreen extends StatefulWidget {
  final StateData chosenState;
  const ChooseStateScreen({super.key, required this.chosenState});

  @override
  State<ChooseStateScreen> createState() => _ChooseStateScreenState();
}

class _ChooseStateScreenState extends State<ChooseStateScreen> {
  List<StateData>? states;

  @override
  void initState() {
    super.initState();
    getStates();
  }

  void getStates() async {
    states = await JsonLoader.loadStates();
    setState(() {});
  }

  Future<void> _selectState(StateData state) async {
    await setString(key: "state", value: state.text);
    currentState = state.text;
    JsonLoader.clearImageQuestionsCache();
    if (!mounted) return;
    goTo(context: context, page: const HomeScreen(), router: false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scheme = Theme.of(context).colorScheme;
    final showBackButton = currentState != null;

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
              SelectionScreenHeader(
                title: 'Wählen Sie ein Bundesland',
                subtitle:
                    'Fragen und Tests werden an Ihr Bundesland angepasst.',
                showBackButton: showBackButton,
              ),

              const SizedBox(height: 20),

              Expanded(
                child: states != null
                    ? ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: states!.length,
                        itemBuilder: (context, index) {
                          final state = states![index];
                          final isSelected =
                              widget.chosenState.text == state.text;

                          return SelectionListTile(
                                title: state.text,
                                imagePath: state.image,
                                isSelected: isSelected,
                                onTap: () => _selectState(state),
                              )
                              .animate()
                              .fadeIn(duration: 280.ms, delay: (40 * index).ms)
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
