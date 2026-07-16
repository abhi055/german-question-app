import 'package:flutter/material.dart';

class QuestionsAppBar extends StatefulWidget {
  final int questionNo;
  final String title;
  const QuestionsAppBar({
    super.key,
    required this.questionNo,
    required this.title,
  });

  @override
  State<QuestionsAppBar> createState() => _QuestionsAppBarState();
}

class _QuestionsAppBarState extends State<QuestionsAppBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 100,
      child: ListTile(
        // Return to home screen button
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        // Aufgabe text
        title: Text(
          "Aufgabe ${widget.questionNo}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // State text
        subtitle: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white38,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        trailing: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Analysis
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 35,
              ),
            ),

            // Star
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.star_border,
                color: Colors.white,
                size: 35,
              ),
            ),

            // Sound
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(
            //     Icons.speaker_outlined,
            //     color: Colors.white,
            //     size: 35,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
