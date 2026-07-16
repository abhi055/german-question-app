import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:question_app/data/data.dart';

ScaffoldFeatureController displaySnackBar({
  required String text,
  required context,
  int durationSec = 2,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(
        child: Text(
          text,
          textDirection: getTextDirectionOnLang(),
          style: GoogleFonts.varela(color: Colors.white, fontSize: 15),
        ),
      ),
      duration: Duration(seconds: durationSec),
      backgroundColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
    ),
  );
}
