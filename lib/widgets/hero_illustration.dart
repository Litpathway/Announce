import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class HeroIllustration extends StatelessWidget {
  const HeroIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    final dayStr = days[now.weekday - 1];
    final dateStr = '$dayStr, ${months[now.month - 1]} ${now.day}';

    return SizedBox(
      height: 175,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = 175.0;
            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Sky gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF060B1A),
                        Color(0xFF0D1B3E),
                        Color(0xFF0A1628),
                      ],
                    ),
                  ),
                ),

                // 2. Stars
                ..._buildStars(w, h),

                // 3. Back mountains
                ClipPath(
                  clipper: _MountainClipper(points: const [
                    Offset(0.00, 1.00), Offset(0.10, 0.55), Offset(0.22, 0.72),
                    Offset(0.36, 0.28), Offset(0.50, 0.52), Offset(0.65, 0.22),
                    Offset(0.80, 0.48), Offset(0.92, 0.33), Offset(1.00, 0.58),
                    Offset(1.00, 1.00),
                  ]),
                  child: Container(color: const Color(0xFF1A2A4A)),
                ),

                // 4. Front mountains
                ClipPath(
                  clipper: _MountainClipper(points: const [
                    Offset(0.00, 1.00), Offset(0.15, 0.52), Offset(0.30, 0.68),
                    Offset(0.46, 0.32), Offset(0.60, 0.58), Offset(0.76, 0.28),
                    Offset(0.90, 0.52), Offset(1.00, 0.42), Offset(1.00, 1.00),
                  ]),
                  child: Container(color: const Color(0xFF0F1F38)),
                ),

                // 5. Water strip
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 30,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF0A1E3D), Color(0xFF0D2244)],
                      ),
                    ),
                  ),
                ),

                // 6. Ship emoji
                const Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text('🚢', style: TextStyle(fontSize: 22)),
                  ),
                ),

                // 7. Glow below ship
                Positioned(
                  bottom: 18,
                  left: w / 2 - 30,
                  child: Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0x1A4F9CF9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x334F9CF9),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),

                // 8. Bottom fade overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          navyBg.withOpacity(0),
                          navyBg,
                        ],
                      ),
                    ),
                  ),
                ),

                // 9. Hero text
                Positioned(
                  top: 16,
                  left: 17,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(greeting, style: syne700(17)),
                      const SizedBox(height: 2),
                      Text(dateStr,
                          style: dmSans300(10, color: textSecondary)),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildStars(double w, double h) {
    final rng = Random(42);
    return List.generate(20, (i) {
      final x = rng.nextDouble() * w;
      final y = rng.nextDouble() * h * 0.6;
      final size = rng.nextDouble() * 1.5 + 1.0;
      final opacity = rng.nextDouble() * 0.5 + 0.2;
      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }
}

class _MountainClipper extends CustomClipper<Path> {
  final List<Offset> points;

  const _MountainClipper({required this.points});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points[0].dx * size.width, points[0].dy * size.height);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_MountainClipper old) => false;
}
