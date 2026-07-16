import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> displayAlert4({
  required BuildContext context,
  required String titleText,
  required String actionBtnText,
  required Function() actionBtnOnPress,
  String? descriptionText,
  IconData icon = Icons.warning_rounded,
  Color actionButtonColor = Colors.red,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final textColor =
          Theme.of(context).textTheme.bodyMedium?.color ??
          (isDark ? Colors.white : Colors.black);

      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: isDark
              ? const Color(0xFF1E1E2C).withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.97),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with glow
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: actionButtonColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: actionButtonColor.withValues(alpha: 0.2),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: actionButtonColor, size: 30),
                  ),

                  const SizedBox(height: 18),

                  // Title
                  Text(
                    titleText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),

                  // Optional description
                  if (descriptionText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      descriptionText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: textColor.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(height: 26),

                  // Buttons
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: textColor.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "Stornieren",
                            style: GoogleFonts.poppins(
                              color: textColor.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Action button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => actionBtnOnPress(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: actionButtonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shadowColor: actionButtonColor.withValues(
                              alpha: 0.3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            actionBtnText,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
