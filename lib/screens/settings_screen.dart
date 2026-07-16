import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:question_app/data/data.dart';
import 'package:question_app/widgets/ad/banner_ad_widget.dart';
import 'package:question_app/widgets/display_custom_modal_sheet.dart';
import 'package:question_app/widgets/display_snackbar.dart';
import 'package:question_app/widgets/settings_list_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color get chosenColor =>
      Theme.of(context).colorScheme.primary.withValues(alpha: 0.2);
  Color get notChosenColor => Theme.of(context).cardTheme.color!;
  String? hoveredState;
  String mode = "Hell";

  @override
  void initState() {
    super.initState();
    mode = themeNotifier.value == ThemeMode.light ? "Hell" : "Dunkel";
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;

    return Scaffold(
      floatingActionButton: const BannerAdWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
            child: Column(
              children: [
                // App bar
                Row(
                  children: [
                    // Go back button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),

                    const SizedBox(width: 30),

                    // All languages text
                    Expanded(
                      child: Text(
                        "Einstellungen",
                        style: GoogleFonts.poppins(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Divider(color: Theme.of(context).dividerTheme.color),

                // Options
                Expanded(
                  child: ListView(
                    children: [
                      // Werbung Text
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          "Werbung",
                          style: GoogleFonts.poppins(
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                            fontSize: isSmallScreen ? 15 : 18,
                          ),
                        ),
                      ),

                      // Werbung
                      SettingsListTile(
                        title: "Werbung entfernen",
                        onPress: () => displayCustomModalSheet(
                          context: context,
                          title: "Enjoy an Ad-Free Experience",
                          subtitle: "Upgrade Now",
                          imagePath: "assets/images/random/noAds.png",
                          onPress: () => displaySnackBar(
                            text: "Not Available",
                            context: context,
                          ),
                          price: 19.99,
                        ),
                        leadingIcon: Icons.ad_units,
                      ),

                      // Kaufe
                      SettingsListTile(
                        title: "Kaufe wiederstellen",
                        onPress: () {},
                        leadingIcon: Icons.restore,
                      ),

                      // Werbeeinwilligung Text
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          "Werbeeinwilligung aktualisieren",
                          style: GoogleFonts.poppins(
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                            fontSize: isSmallScreen ? 15 : 18,
                          ),
                        ),
                      ),

                      // Einwilligung widerrufen
                      SettingsListTile(
                        title: "Einwilligung widerrufen",
                        onPress: () => displaySnackBar(
                          text: "Noch nicht verfügbar!s",
                          context: context,
                        ),
                        leadingIcon: Icons.cookie_outlined,
                      ),

                      // Bewetung Text
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          "Bewetung",
                          style: GoogleFonts.poppins(
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                            fontSize: isSmallScreen ? 15 : 18,
                          ),
                        ),
                      ),

                      // Bewetung
                      SettingsListTile(
                        title: "Bewetung",
                        onPress: () => displaySnackBar(
                          text: "Noch nicht verfügbar!s",
                          context: context,
                        ),
                        leadingIcon: Icons.message_outlined,
                      ),

                      // Text
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          "Andere Optionen",
                          style: GoogleFonts.poppins(
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                            fontSize: isSmallScreen ? 15 : 18,
                          ),
                        ),
                      ),

                      // Andere Optionen
                      SettingsListTile(
                        title: themeNotifier.value == ThemeMode.light
                            ? "Dunkel"
                            : themeNotifier.value == ThemeMode.dark
                            ? "Hell"
                            : "System",
                        onPress: () {
                          if (themeNotifier.value == ThemeMode.light) {
                            themeNotifier.value = ThemeMode.dark;
                          } else if (themeNotifier.value == ThemeMode.dark) {
                            themeNotifier.value = ThemeMode.light;
                          } else {
                            themeNotifier.value = ThemeMode.dark;
                          }
                          setState(() {});
                        },
                        leadingIcon: themeNotifier.value == ThemeMode.light
                            ? Icons.star_half
                            : themeNotifier.value == ThemeMode.dark
                            ? Icons.star
                            : Icons.lightbulb,
                      ),

                      // Tailen Optionen
                      SettingsListTile(
                        title: "Tailen",
                        onPress: () {
                          displaySnackBar(
                            text: "Noch nicht verfügbar!s",
                            context: context,
                          );
                        },
                        leadingIcon: Icons.share_outlined,
                      ),

                      // Kontakte
                      SettingsListTile(
                        title: "Kontakte",
                        onPress: () {
                          displaySnackBar(
                            text: "Noch nicht verfügbar!s",
                            context: context,
                          );
                        },
                        leadingIcon: Icons.mail_outline,
                      ),

                      const SizedBox(height: 200),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
