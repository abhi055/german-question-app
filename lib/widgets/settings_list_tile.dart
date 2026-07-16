import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsListTile extends StatefulWidget {
  final String title;
  final Function() onPress;
  final IconData leadingIcon;
  const SettingsListTile({
    super.key,
    required this.title,
    required this.onPress,
    required this.leadingIcon,
  });

  @override
  State<SettingsListTile> createState() => _SettingsListTileState();
}

class _SettingsListTileState extends State<SettingsListTile> {
  bool isHoveredState = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4.0 : 8.0),
      child: GestureDetector(
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
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: ListTile(
              onTap: () => widget.onPress(),
              contentPadding: EdgeInsets.all(isSmallScreen ? 8 : 11),
              // Language image
              leading: Icon(
                widget.leadingIcon,
                color: Theme.of(context).iconTheme.color,
                size: isSmallScreen ? 20 : 24,
              ),
              title: Text(
                widget.title,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 15 : 18,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
                size: isSmallScreen ? 16 : 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
