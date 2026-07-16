import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectionScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final VoidCallback? onBack;

  const SelectionScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (showBackButton)
              _HeaderIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onPressed: onBack ?? () => Navigator.of(context).pop(),
              )
            else
              const SizedBox(width: 48),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 14,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Auswahl',
                    style: GoogleFonts.poppins(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: scheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 22 : 26,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: scheme.onSurface.withValues(alpha: 0.65),
            fontSize: isSmallScreen ? 13 : 15,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark
          ? scheme.surfaceContainerHighest
          : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      shadowColor: scheme.shadow.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 18, color: scheme.onSurface),
        ),
      ),
    );
  }
}
