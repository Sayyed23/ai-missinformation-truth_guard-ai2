import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:truth_guard_ai/core/navigation/app_router.dart';

void main() {
  runApp(const ProviderScope(child: TruthGuardApp()));
}

class TruthGuardApp extends StatelessWidget {
  const TruthGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Truth Guard AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      routerConfig: appRouter,
    );
  }
}

// Small sample widget showing the logo asset. This widget isn't wired
// into routing; it's provided as a quick reference for how to use the
// `assets/logo.png` file added to `pubspec.yaml`.

class LogoSample extends StatelessWidget {
  const LogoSample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TruthGuard AI'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 240,
                height: 240,
                child: Image.asset('assets/logo.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              const Text('TruthGuard AI', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}
