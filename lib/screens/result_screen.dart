import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:question_app/database/saved_db_data.dart';
import 'package:question_app/database/shared_pref.dart';
import 'package:question_app/functions/go_to.dart';
import 'package:question_app/screens/home_screen.dart';

class ResultScreen extends StatefulWidget {
  final String title;
  final int testQuestionsLength;
  final int correctAnswersCount;
  final int incorrectAnswersCount;
  const ResultScreen({
    super.key,
    required this.title,
    required this.testQuestionsLength,
    required this.correctAnswersCount,
    required this.incorrectAnswersCount,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _floatingController;
  late Animation<double> _progressAnimation;
  bool showHomeScreenButton = false;

  // Pre-generated floating circle data
  late final List<_FloatingCircle> _floatingCircles;

  @override
  void initState() {
    super.initState();
    saveResult();

    final targetProgress = widget.testQuestionsLength > 0
        ? widget.correctAnswersCount / widget.testQuestionsLength
        : 0.0;

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _progressAnimation = Tween<double>(begin: 0, end: targetProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Generate floating circles once
    final rng = Random(42);
    _floatingCircles = List.generate(12, (i) {
      return _FloatingCircle(
        left: rng.nextDouble(),
        top: rng.nextDouble(),
        size: rng.nextDouble() * 60 + 20,
        speed: rng.nextDouble() * 0.5 + 0.5,
        phase: rng.nextDouble() * 2 * pi,
        opacity: rng.nextDouble() * 0.12 + 0.04,
      );
    });

    _progressController.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          showHomeScreenButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  // Save test result
  void saveResult() async {
    await SavedDbData().insertTestResult(
      correctCount: widget.correctAnswersCount,
      incorrectCount: widget.incorrectAnswersCount,
    );
    if (widget.correctAnswersCount > widget.testQuestionsLength / 2) {
      int count = await getInt(key: "passTestCount", defaultValue: 0);
      await setInt(key: "passTestCount", value: ++count);
    } else {
      int count = await getInt(key: "failTestCount", defaultValue: 0);
      await setInt(key: "failTestCount", value: ++count);
    }
  }

  // Passed or not
  bool checkIsPassed() {
    return widget.correctAnswersCount >= widget.testQuestionsLength / 2;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.width < 380;
    final isPassed = checkIsPassed();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Color palette based on pass/fail
    final primaryGradientStart = isPassed
        ? (isDark ? const Color(0xFF1A3A2A) : const Color(0xFFE8F5E9))
        : (isDark ? const Color(0xFF3A1A1A) : const Color(0xFFFCE4EC));
    final primaryGradientEnd = isDark
        ? Theme.of(context).scaffoldBackgroundColor
        : const Color(0xFFF8F9FA);

    final accentColor = isPassed
        ? const Color(0xFF4CAF50)
        : const Color(0xFFE53935);
    final accentColorLight = isPassed
        ? const Color(0xFF81C784)
        : const Color(0xFFEF9A9A);

    final progressRingSize = isSmallScreen ? 160.0 : 200.0;
    final percentage = widget.testQuestionsLength > 0
        ? (widget.correctAnswersCount / widget.testQuestionsLength * 100)
              .round()
        : 0;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryGradientStart, primaryGradientEnd],
                stops: const [0.0, 0.6],
              ),
            ),
          ),

          // Floating decorative circles
          AnimatedBuilder(
            animation: _floatingController,
            builder: (context, _) {
              return Stack(
                children: _floatingCircles.map((circle) {
                  final offset = sin(
                    _floatingController.value * 2 * pi * circle.speed +
                        circle.phase,
                  ) * 20;
                  return Positioned(
                    left: circle.left * size.width - circle.size / 2,
                    top: circle.top * size.height -
                        circle.size / 2 +
                        offset,
                    child: Container(
                      width: circle.size,
                      height: circle.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: circle.opacity),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06,
                ),
                child: Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 30 : 50),

                    // Title
                    Text(
                      widget.title,
                      style: GoogleFonts.poppins(
                        color:
                            Theme.of(context).textTheme.titleLarge?.color,
                        fontWeight: FontWeight.w700,
                        fontSize: isSmallScreen ? 22 : 28,
                        letterSpacing: -0.5,
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: 600.ms,
                          delay: 200.ms,
                        )
                        .slideY(
                          begin: -0.3,
                          end: 0,
                          duration: 600.ms,
                          delay: 200.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    SizedBox(height: isSmallScreen ? 30 : 50),

                    // Circular progress ring
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        final currentCount =
                            (_progressAnimation.value *
                                    widget.testQuestionsLength)
                                .round();
                        return SizedBox(
                          width: progressRingSize,
                          height: progressRingSize,
                          child: CustomPaint(
                            painter: _ScoreRingPainter(
                              progress: _progressAnimation.value,
                              accentColor: accentColor,
                              accentColorLight: accentColorLight,
                              trackColor: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.06),
                              strokeWidth: isSmallScreen ? 12 : 14,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "$currentCount",
                                    style: GoogleFonts.poppins(
                                      color: accentColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize:
                                          isSmallScreen ? 42 : 52,
                                      height: 1.0,
                                    ),
                                  ),
                                  Text(
                                    "von ${widget.testQuestionsLength}",
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w500,
                                      fontSize:
                                          isSmallScreen ? 13 : 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 400.ms)
                        .scale(
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1, 1),
                          duration: 700.ms,
                          delay: 400.ms,
                          curve: Curves.easeOutBack,
                        ),

                    SizedBox(height: isSmallScreen ? 20 : 32),

                    // Pass / Fail badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPassed
                              ? [
                                  const Color(0xFF43A047),
                                  const Color(0xFF66BB6A),
                                ]
                              : [
                                  const Color(0xFFE53935),
                                  const Color(0xFFEF5350),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isPassed ? "🎉" : "😔",
                            style: TextStyle(
                              fontSize: isSmallScreen ? 22 : 26,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isPassed ? "Bestanden!" : "Nicht bestanden",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: isSmallScreen ? 18 : 22,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 900.ms)
                        .slideY(
                          begin: 0.5,
                          end: 0,
                          duration: 500.ms,
                          delay: 900.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 8),

                    // Percentage subtitle
                    Text(
                      "$percentage% richtig",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                        fontSize: isSmallScreen ? 13 : 15,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 1100.ms),

                    SizedBox(height: isSmallScreen ? 24 : 36),

                    // Score breakdown card (glassmorphism)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Correct answers row
                          _buildStatRow(
                            context: context,
                            label: "Richtige Antworten",
                            count: widget.correctAnswersCount,
                            total: widget.testQuestionsLength,
                            color: const Color(0xFF4CAF50),
                            icon: Icons.check_circle_rounded,
                            isSmallScreen: isSmallScreen,
                          ),

                          const SizedBox(height: 20),

                          // Divider
                          Container(
                            height: 1,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),

                          const SizedBox(height: 20),

                          // Incorrect answers row
                          _buildStatRow(
                            context: context,
                            label: "Falsche Antworten",
                            count: widget.incorrectAnswersCount,
                            total: widget.testQuestionsLength,
                            color: const Color(0xFFE53935),
                            icon: Icons.cancel_rounded,
                            isSmallScreen: isSmallScreen,
                          ),

                          const SizedBox(height: 20),

                          // Divider
                          Container(
                            height: 1,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),

                          const SizedBox(height: 20),

                          // Unanswered row
                          _buildStatRow(
                            context: context,
                            label: "Nicht beantwortet",
                            count: widget.testQuestionsLength -
                                widget.correctAnswersCount -
                                widget.incorrectAnswersCount,
                            total: widget.testQuestionsLength,
                            color: Colors.grey,
                            icon: Icons.remove_circle_rounded,
                            isSmallScreen: isSmallScreen,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 1300.ms)
                        .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          delay: 1300.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    SizedBox(height: isSmallScreen ? 24 : 36),

                    // Home button
                    if (showHomeScreenButton)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => goTo(
                                context: context,
                                page: const HomeScreen(),
                                router: false,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.home_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Startseite",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 18 : 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 200.ms)
                          .slideY(
                            begin: 0.4,
                            end: 0,
                            duration: 500.ms,
                            delay: 200.ms,
                            curve: Curves.easeOutCubic,
                          ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required BuildContext context,
    required String label,
    required int count,
    required int total,
    required Color color,
    required IconData icon,
    required bool isSmallScreen,
  }) {
    final barFraction = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: isSmallScreen ? 20 : 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
            Text(
              "$count",
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: isSmallScreen ? 20 : 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Animated progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            width: double.infinity,
            child: Stack(
              children: [
                // Track
                Container(
                  color: color.withValues(alpha: 0.12),
                ),
                // Fill
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    final animatedWidth = barFraction *
                        Curves.easeOutCubic.transform(
                          _progressController.value,
                        );
                    return FractionallySizedBox(
                      widthFactor: animatedWidth.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color,
                              color.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Data class for floating circles
class _FloatingCircle {
  final double left;
  final double top;
  final double size;
  final double speed;
  final double phase;
  final double opacity;

  const _FloatingCircle({
    required this.left,
    required this.top,
    required this.size,
    required this.speed,
    required this.phase,
    required this.opacity,
  });
}

// Custom painter for the circular progress ring
class _ScoreRingPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final Color accentColorLight;
  final Color trackColor;
  final double strokeWidth;

  _ScoreRingPainter({
    required this.progress,
    required this.accentColor,
    required this.accentColorLight,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final sweepAngle = 2 * pi * progress;
      final rect = Rect.fromCircle(center: center, radius: radius);

      final progressPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: -pi / 2 + sweepAngle,
          colors: [accentColor, accentColorLight, accentColor],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Glow dot at the end
      final dotAngle = -pi / 2 + sweepAngle;
      final dotCenter = Offset(
        center.dx + radius * cos(dotAngle),
        center.dy + radius * sin(dotAngle),
      );

      final glowPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(dotCenter, strokeWidth * 0.8, glowPaint);

      final dotPaint = Paint()..color = accentColor;
      canvas.drawCircle(dotCenter, strokeWidth * 0.45, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
