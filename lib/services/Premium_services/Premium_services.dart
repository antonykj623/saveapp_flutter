import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_project_2025/services/API_services/API_services.dart'
    show ApiHelper;

class PremiumStatus {
  final bool isActive;
  final int daysRemaining;
  final String message;
  final String? initialDate;
  final String? endDate;

  final bool isTrialExpired;
  final int trialDaysRemaining;
  final String? trialEndDate;
  final bool isPremium;

  final String? salesDate;
  final String? expeDate;
  final int? salesId;
  final int? productId;

  PremiumStatus({
    required this.isActive,
    required this.daysRemaining,
    required this.message,
    this.initialDate,
    this.endDate,
    this.isTrialExpired = false,
    this.trialDaysRemaining = 0,
    this.trialEndDate,
    this.isPremium = false,
    this.salesDate,
    this.expeDate,
    this.salesId,
    this.productId,
  });

  factory PremiumStatus.fromJson(Map<String, dynamic> json) {
    // Handle nested sales_data properly
    final salesData = json['sales_data'] as Map<String, dynamic>?;

    final int? salesId =
        salesData != null
            ? (salesData['id'] is int
                ? salesData['id']
                : int.tryParse(salesData['id']?.toString() ?? ''))
            : null;

    final int? productId =
        salesData != null
            ? (salesData['product_id'] is int
                ? salesData['product_id']
                : int.tryParse(salesData['product_id']?.toString() ?? ''))
            : null;

    final String? salesDateStr = salesData?['sales_date']?.toString();
    final String? expeDateStr = salesData?['expe_date']?.toString();
    final String? trialEndDateStr = json['trialenddate']?.toString();
    final String? currentDateStr = json['current_date']?.toString();

    final now =
        (currentDateStr != null && currentDateStr.isNotEmpty)
            ? DateTime.tryParse(currentDateStr) ?? DateTime.now()
            : DateTime.now();

    bool isTrialExpired = true;
    int trialDaysRemaining = 0;
    bool isSalesValid = false;
    int salesDaysRemaining = 0;

    // === Handle Paid Subscription (sales_data) ===
    if (salesId != null &&
        salesId != 0 &&
        salesDateStr != null &&
        expeDateStr != null) {
      try {
        final salesDate = DateTime.parse(salesDateStr);
        final expeDate = DateTime.parse(expeDateStr);

        isSalesValid =
            now.isAfter(salesDate.subtract(const Duration(days: 1))) &&
            now.isBefore(expeDate.add(const Duration(days: 1)));

        if (isSalesValid) {
          salesDaysRemaining = expeDate.difference(now).inDays.clamp(0, 999);
        }
      } catch (e) {
        isSalesValid = false;
      }
    }

    // === Handle Trial (if no valid sales) ===
    if (!isSalesValid &&
        trialEndDateStr != null &&
        trialEndDateStr.isNotEmpty) {
      try {
        final trialEndDate = DateTime.parse(trialEndDateStr);
        final diff = trialEndDate.difference(now);
        trialDaysRemaining = diff.inDays.clamp(0, 999);
        isTrialExpired = trialDaysRemaining <= 0;
      } catch (e) {
        isTrialExpired = true;
      }
    }

    // === Special Rule: Product ID 2 → Always Active ===
    final bool forceActive = productId == 2;

    final bool hasActiveSubscription = isSalesValid;
    final bool hasActiveTrial =
        !isTrialExpired && (salesId == null || salesId == 0);

    final bool canAccess =
        forceActive || hasActiveSubscription || hasActiveTrial;

    final int effectiveDays =
        forceActive
            ? 999
            : (hasActiveSubscription ? salesDaysRemaining : trialDaysRemaining);

    return PremiumStatus(
      isActive: canAccess,
      daysRemaining: effectiveDays,
      message: canAccess ? 'Access granted' : 'Access expired',
      initialDate: hasActiveSubscription ? salesDateStr : null,
      endDate: hasActiveSubscription ? expeDateStr : trialEndDateStr,
      isTrialExpired: isTrialExpired || forceActive,
      trialDaysRemaining: forceActive ? 999 : trialDaysRemaining,
      trialEndDate: trialEndDateStr,
      isPremium: hasActiveSubscription,
      salesDate: salesDateStr,
      expeDate: expeDateStr,
      salesId: salesId,
      productId: productId,
    );
  }

  factory PremiumStatus.expired() => PremiumStatus(
    isActive: false,
    daysRemaining: 0,
    message: 'Premium expired',
    isTrialExpired: true,
  );

  factory PremiumStatus.active() => PremiumStatus(
    isActive: true,
    daysRemaining: 999,
    message: 'Premium active',
    isPremium: true,
  );
}

class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  PremiumStatus? _cachedStatus;
  DateTime? _lastChecked;
  final Duration _cacheExpiration = const Duration(minutes: 5);

  Future<PremiumStatus> checkPremiumStatus({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedStatus != null &&
        _lastChecked != null &&
        DateTime.now().difference(_lastChecked!) < _cacheExpiration) {
      return _cachedStatus!;
    }

    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final response = await ApiHelper().postApiResponse(
        'checkPremiumDates.php',
        {'timestamp': timestamp},
      );
      final data = json.decode(response);
      _cachedStatus = PremiumStatus.fromJson(data);
      _lastChecked = DateTime.now();
      return _cachedStatus!;
    } catch (e) {
      _cachedStatus = PremiumStatus.expired();
      return _cachedStatus!;
    }
  }

  PremiumStatus? getCachedStatus() => _cachedStatus;

  void clearCache() {
    _cachedStatus = null;
    _lastChecked = null;
  }

  Future<bool> isPremiumActive({bool forceRefresh = false}) async {
    final status = await checkPremiumStatus(forceRefresh: forceRefresh);
    return status.isActive;
  }

  Future<bool> canAddData({bool forceRefresh = false}) async {
    final status = await checkPremiumStatus(forceRefresh: forceRefresh);
    return status.productId == 2 || status.isActive;
  }

  // Dialog
  static void showPremiumExpiredDialog(
    BuildContext context, {
    String? customMessage,
    VoidCallback? onUpgrade,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Premium Required',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              customMessage ??
                  'Your access has expired. Upgrade to premium to continue.',
              textAlign: TextAlign.center,
            ),
            actions: [
              if (onUpgrade != null)
                TextButton.icon(
                  icon: const Icon(Icons.upgrade, color: Colors.teal),
                  label: const Text('Upgrade Now'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onUpgrade();
                  },
                ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Later'),
              ),
            ],
          ),
    );
  }

  // Banner
  static Widget buildPremiumBanner({
    required BuildContext context,
    required PremiumStatus status,
    required bool isChecking,
    VoidCallback? onRefresh,
  }) {
    final size = MediaQuery.of(context).size;

    if (isChecking) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: const Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            SizedBox(width: 10),
            Text('Checking access status...'),
          ],
        ),
      );
    }

    // Product 2 → Always show full access
    if (status.productId == 2) {
      return _buildBannerBox(
        size,
        icon: Icons.verified_user,
        color: Colors.green,
        title: 'Full Access Granted',
        subtitle: 'Product 2 • Unlimited Features',
        onRefresh: onRefresh,
      );
    }

    // Expired trial (no sales)
    if (status.isTrialExpired &&
        (status.salesId == null || status.salesId == 0)) {
      return _buildBannerBox(
        size,
        icon: Icons.lock,
        color: Colors.red,
        title: 'Trial Expired',
        subtitle: 'Upgrade to premium to continue',
        onRefresh: onRefresh,
      );
    }

    // Expired premium
    if (!status.isActive && status.isPremium) {
      return _buildBannerBox(
        size,
        icon: Icons.lock_clock,
        color: Colors.orange[700]!,
        title: 'Premium Expired',
        subtitle: 'Renew your subscription',
        onRefresh: onRefresh,
      );
    }

    // Active (trial or premium)
    final daysLeft = status.daysRemaining;
    final isWarning = daysLeft <= 7;
    final isTrial = !status.isPremium;

    return _buildBannerBox(
      size,
      icon: isWarning ? Icons.warning_amber_rounded : Icons.check_circle,
      color: isWarning ? Colors.orange : Colors.green,
      title: isTrial ? 'Trial Active' : 'Premium Active',
      subtitle: '$daysLeft days ${isTrial ? 'left in trial' : 'remaining'}',
      onRefresh: onRefresh,
    );
  }

  static Widget _buildBannerBox(
    Size size, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onRefresh,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: Icon(Icons.refresh, color: color),
              onPressed: onRefresh,
            ),
        ],
      ),
    );
  }
}
