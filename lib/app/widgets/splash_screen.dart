import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _implodeController;

  final String logoUrl = "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQa85Mr3rqsBeXwpHZKrCQiyIXjXySFQIRkWBCkpbMXXHPfkps";
  final List<IconData> beautyIcons = [
    Icons.face,
    Icons.spa,
    Icons.favorite,
    Icons.healing,
    Icons.masks,
    Icons.waves,
    Icons.accessibility_new,
    Icons.emoji_emotions,
    Icons.medical_services,
    Icons.mood,
  ];
  // Add more icons for richer layers
  final List<IconData> layer2Icons = [
    Icons.face_6,
    Icons.face_3,
    Icons.face_retouching_natural,
    Icons.mood,
    Icons.emoji_people,
    Icons.favorite_border,
    Icons.spa,
    Icons.healing,
    Icons.masks,
    Icons.waves,
  ];
  final List<IconData> layer3Icons = [
    Icons.accessibility_new,
    Icons.accessibility,
    Icons.accessible_forward,
    Icons.directions_walk,
    Icons.directions_run,
    Icons.fitness_center,
    Icons.sports_gymnastics,
    Icons.sports_mma,
    Icons.pan_tool_alt,
    Icons.back_hand,
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _implodeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    // Start implode animation before finishing splash
    Future.delayed(const Duration(seconds: 2), () {
      _implodeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 2900), widget.onFinish);
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _implodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double logoSize = size.width * 0.32;
    final double orbitRadius = size.width * 0.36;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Stack(
        children: [
          // Glassmorphism background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF0A0E21),
                  const Color(0xFF1A237E),
                  const Color(0xFF0A0E21),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Multi-layer orbiting then imploding icons
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_orbitController, _implodeController]),
              builder: (context, child) {
                final double angle = _orbitController.value * 2 * math.pi;
                final double implodeT = _implodeController.value;
                // Layer radii and speeds
                final double orbitRadius1 = size.width * 0.36;
                final double orbitRadius2 = size.width * 0.48;
                final double orbitRadius3 = size.width * 0.60;
                final double speed1 = 1.0;
                final double speed2 = -0.7;
                final double speed3 = 0.5;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Layer 1
                    for (int i = 0; i < beautyIcons.length; i++)
                      Transform.translate(
                        offset: Offset(
                          (orbitRadius1 * (1 - implodeT)) * math.cos(angle * speed1 + i * 2 * math.pi / beautyIcons.length),
                          (orbitRadius1 * (1 - implodeT)) * math.sin(angle * speed1 + i * 2 * math.pi / beautyIcons.length),
                        ),
                        child: Opacity(
                          opacity: 1.0 - implodeT,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(
                              beautyIcons[i],
                              color: i % 2 == 0 ? Colors.orangeAccent : Colors.blue[900],
                              size: 32 * (1 - implodeT * 0.5),
                            ),
                          ),
                        ),
                      ),
                    // Layer 2
                    for (int i = 0; i < layer2Icons.length; i++)
                      Transform.translate(
                        offset: Offset(
                          (orbitRadius2 * (1 - implodeT)) * math.cos(angle * speed2 + i * 2 * math.pi / layer2Icons.length + 0.5),
                          (orbitRadius2 * (1 - implodeT)) * math.sin(angle * speed2 + i * 2 * math.pi / layer2Icons.length + 0.5),
                        ),
                        child: Opacity(
                          opacity: 0.8 * (1.0 - implodeT),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.13),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.07),
                                  blurRadius: 7,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              layer2Icons[i],
                              color: i % 2 == 0 ? Colors.blue[900] : Colors.orangeAccent,
                              size: 26 * (1 - implodeT * 0.5),
                            ),
                          ),
                        ),
                      ),
                    // Layer 3
                    for (int i = 0; i < layer3Icons.length; i++)
                      Transform.translate(
                        offset: Offset(
                          (orbitRadius3 * (1 - implodeT)) * math.cos(angle * speed3 + i * 2 * math.pi / layer3Icons.length - 0.7),
                          (orbitRadius3 * (1 - implodeT)) * math.sin(angle * speed3 + i * 2 * math.pi / layer3Icons.length - 0.7),
                        ),
                        child: Opacity(
                          opacity: 0.6 * (1.0 - implodeT),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.11),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              layer3Icons[i],
                              color: i % 2 == 0 ? Colors.orangeAccent : Colors.blue[900],
                              size: 20 * (1 - implodeT * 0.5),
                            ),
                          ),
                        ),
                      ),
                    // Centered logo with Hero
                    Hero(
                      tag: 'main_logo',
                      child: Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 18,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.network(
                            logoUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 