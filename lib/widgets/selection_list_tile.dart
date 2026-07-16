import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectionListTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionListTile({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isSelected
        ? scheme.primary.withValues(alpha: isDark ? 0.24 : 0.12)
        : isDark
        ? scheme.surfaceContainerHighest
        : Colors.white;

    final borderColor = isSelected
        ? scheme.primary
        : scheme.outline.withValues(alpha: isDark ? 0.35 : 0.2);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 5 : 7),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: scheme.primary.withValues(alpha: 0.12),
          highlightColor: scheme.primary.withValues(alpha: 0.08),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? null
                  : [
                      BoxShadow(
                        color: scheme.shadow.withValues(
                          alpha: isDark ? 0.25 : 0.06,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 10 : 14,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(
                        alpha: isDark ? 0.18 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        width: isSmallScreen ? 40 : 52,
                        height: isSmallScreen ? 40 : 52,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: scheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        fontSize: isSmallScreen ? 15 : 17,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: scheme.onPrimary,
                        size: isSmallScreen ? 16 : 18,
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: scheme.onSurface.withValues(alpha: 0.45),
                      size: isSmallScreen ? 22 : 26,
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
