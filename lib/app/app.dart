// 📚 What we're learning:
// - MaterialApp.router = uses GoRouter for navigation
// - We give it our theme AND our router → everything connects!

import 'package:flutter/material.dart';
import '../app/theme/app_theme.dart';
import '../app/router/app_router.dart';

class ClipCraftApp extends StatelessWidget {
  const ClipCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App name shown in task switcher
      title: 'ClipCraft AI',

      // Turn off debug banner in top-right corner
      debugShowCheckedModeBanner: false,

      // 🎨 Use our theme! Colors + text styles from Step 6
      theme: AppTheme.darkTheme,

      // 🧭 Use our router! Navigation from Step 8
      routerConfig: appRouter,
    );
  }
}
