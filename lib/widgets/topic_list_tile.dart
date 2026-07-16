import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopicListTile extends StatefulWidget {
  final String title;
  final String iconImgPath;
  final void Function() onPress;
  final bool showQuestionsLength;
  final int questionsLength;
  final Color? imageColor;
  const TopicListTile({
    super.key,
    required this.title,
    required this.iconImgPath,
    required this.onPress,
    this.questionsLength = 0,
    this.showQuestionsLength = true,
    this.imageColor,
  });

  @override
  State<TopicListTile> createState() => _TopicListTileState();
}

class _TopicListTileState extends State<TopicListTile> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;

    return GestureDetector(
      // Choose question category button
      onTap: () {
        widget.onPress();
      },
      onTapDown: (_) => setState(() {
        hovered = true;
      }),
      onTapUp: (_) => setState(() {
        hovered = false;
      }),
      onTapCancel: () => setState(() {
        hovered = false;
      }),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6.0 : 8.0),
        child: Opacity(
          opacity: hovered ? 0.5 : 1,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 8.0 : 12.0),
              child: Row(
                children: [
                  // Quiz image
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                        child: Image.asset(
                          widget.iconImgPath,
                          width: isSmallScreen ? 32 : 44,
                          height: isSmallScreen ? 32 : 44,
                          color: widget.imageColor,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: isSmallScreen ? 12 : 20),

                  // Title text
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: isSmallScreen ? 15 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Questions length and Forward icon
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Questions length
                        if (widget.showQuestionsLength)
                          Text(
                            widget.questionsLength.toString(),
                            textAlign: TextAlign.end,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                        const SizedBox(width: 10),

                        // Forward icon
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withValues(alpha: 0.5),
                          size: 16,
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
    );
  }
}
