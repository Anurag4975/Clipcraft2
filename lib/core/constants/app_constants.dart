// 📚 What we're learning:
// - "class with static const" = a simple container for fixed values
// - "const" = value never changes, compiled directly into app = faster & smaller
// - One file to rule them all! Change prices/limits here only.

class AppConstants {
  // ──────────────────────────────────────────────
  // App Info
  // ──────────────────────────────────────────────
  static const String appName = 'ClipCraft AI';
  static const String appVersion = '0.1.0';

  // ──────────────────────────────────────────────
  // API Settings
  // ──────────────────────────────────────────────
  static const String baseUrl = 'https://api.clipcraft-ai.com/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // ──────────────────────────────────────────────
  // Subscription & Pricing
  // ──────────────────────────────────────────────
  static const double creatorProMonthlyPrice = 4.99;
  static const double creatorProYearlyPrice = 49.99;
  static const double studioMonthlyPrice = 9.99;
  static const double studioYearlyPrice = 99.99;

  // ──────────────────────────────────────────────
  // Free Tier Limits
  // ──────────────────────────────────────────────
  static const int freeDailyAILimit = 5; // 5 AI clips per day
  static const int freeMaxVideoDuration = 300; // 5 minutes in seconds
  static const int freeMaxExportResolution = 1080; // Full HD

  // ──────────────────────────────────────────────
  // Storage Keys
  // ──────────────────────────────────────────────
  static const String boxProjects = 'projects_box';
  static const String boxSubscription = 'subscription_box';
  static const String boxSettings = 'settings_box';
}
