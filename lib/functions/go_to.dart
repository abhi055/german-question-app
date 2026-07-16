import 'package:flutter/material.dart';

void goTo({
  required BuildContext context,
  required Widget page,
  bool router = true,
  void Function()? onPress,
}) {
  Navigator.of(context)
      .pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => page,
          transitionDuration: const Duration(milliseconds: 300),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            // New page: right → center
            final slideIn =
                Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                );

            // Old page: center → slightly left (parallax)
            final slideOut =
                Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-0.3, 0),
                ).animate(
                  CurvedAnimation(
                    parent: secondaryAnimation,
                    curve: Curves.easeOut,
                  ),
                );

            return Stack(
              children: [
                SlideTransition(
                  position: slideOut,
                  child: const SizedBox.expand(), // placeholder for old page
                ),
                SlideTransition(position: slideIn, child: child),
              ],
            );
          },
        ),

        // keep your original behavior
        (route) => router,
      )
      .then((_) => onPress?.call());
}
