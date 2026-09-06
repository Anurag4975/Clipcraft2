import 'package:hive/hive.dart';
import '../constants/app_constants.dart';
import '../enums/subscription_tier.dart';

/// Tracks daily cloud-analysis usage and enforces per-tier limits.
/// On-device analysis is never limited by this service — it's always free.
class UsageService {
  final Box _box; // AppConstants.boxSubscription

  static const _kTier = 'tier';
  static const _kCloudUsageCount = 'cloudUsageCount';
  static const _kLastUsageDate = 'lastUsageDate'; // yyyy-MM-dd

  UsageService(this._box);

  SubscriptionTier getCurrentTier() {
    final raw = _box.get(_kTier) as String?;
    return SubscriptionTier.values.firstWhere(
      (t) => t.name == raw,
      orElse: () => SubscriptionTier.free,
    );
  }

  Future<void> setTier(SubscriptionTier tier) async {
    await _box.put(_kTier, tier.name);
  }

  int _limitForTier(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.free:
        return AppConstants.freeCloudAnalysisLimit;
      case SubscriptionTier.creatorPro:
        return AppConstants.creatorProCloudAnalysisLimit;
      case SubscriptionTier.studio:
        return AppConstants.studioCloudAnalysisLimit;
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Resets the counter if the stored date isn't today.
  Future<void> _resetIfNewDay() async {
    final lastDate = _box.get(_kLastUsageDate) as String?;
    final today = _todayKey();
    if (lastDate != today) {
      await _box.put(_kLastUsageDate, today);
      await _box.put(_kCloudUsageCount, 0);
    }
  }

  Future<int> getCloudUsageToday() async {
    await _resetIfNewDay();
    return (_box.get(_kCloudUsageCount) as int?) ?? 0;
  }

  Future<int> getDailyLimit() async {
    return _limitForTier(getCurrentTier());
  }

  Future<int> getRemainingCloudUses() async {
    final used = await getCloudUsageToday();
    final limit = await getDailyLimit();
    final remaining = limit - used;
    return remaining < 0 ? 0 : remaining;
  }

  Future<bool> canUseCloud() async {
    return (await getRemainingCloudUses()) > 0;
  }

  Future<void> recordCloudUsage() async {
    await _resetIfNewDay();
    final current = (_box.get(_kCloudUsageCount) as int?) ?? 0;
    await _box.put(_kCloudUsageCount, current + 1);
  }
}
