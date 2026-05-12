import 'package:flutter/material.dart';
import 'package:qibla_compass/qibla_compass.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qibla Compass Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A2E24),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Default theme ────────────────────────────────────────────────
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFCDA047),
                foregroundColor: const Color(0xFF0A2E24),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QiblaScreen(),
                ),
              ),
              child: const Text(
                'فتح البوصلة  ·  Open Qibla Compass',
                style: TextStyle(fontFamily: 'Amiri', fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),

            // ── Midnight theme ───────────────────────────────────────────────
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2A6C),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QiblaScreen(
                    theme: QiblaTheme.midnightTheme,
                  ),
                ),
              ),
              child: const Text(
                'Midnight Theme',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
