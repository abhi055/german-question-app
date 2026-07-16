import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

dynamic displayCustomModalSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required String imagePath,
  required double price,
  required Function() onPress,
}) {
  final screenHeight = MediaQuery.heightOf(context);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: Image.asset(
                  imagePath,
                  height: screenHeight / 3,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Title text
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.varela(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Subtitle Text
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.varela(color: Colors.white, fontSize: 20),
                ),
              ),

              // On Press Button
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Only \$$price",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize: WidgetStatePropertyAll(
                          Size(double.maxFinite, 60),
                        ),
                        backgroundColor: WidgetStatePropertyAll(
                          const Color.fromARGB(255, 255, 187, 0),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Unlock Now",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
