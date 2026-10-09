import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

enum ExtraFeature { transactionHistory, mobileRecharge, qrPayment }

enum FeatureState { locked, unlockedHidden, active }

@immutable
class UnlockThresholds {
  const UnlockThresholds({
    this.opsWithoutHelp = 5,
    this.practiceSessions = 3,
    this.maxRejections = 3,
  });

  final int opsWithoutHelp;
  final int practiceSessions;
  final int maxRejections;
}

@immutable
class ExtraFeatureConfig {
  const ExtraFeatureConfig({
    required this.feature,
    required this.nameKey,
    required this.descriptionKey,
    required this.proposalMessageKey,
    required this.iconData,
    required this.route,
  });

  final ExtraFeature feature;
  final String nameKey;
  final String descriptionKey;
  final String proposalMessageKey;
  final IconData iconData;
  final String route;

  static const List<ExtraFeatureConfig> all = [
    ExtraFeatureConfig(
      feature: ExtraFeature.transactionHistory,
      nameKey: 'unlock_feature_transactions',
      descriptionKey: 'unlock_desc_transactions',
      proposalMessageKey: 'unlock_proposal_transactions',
      iconData: Icons.receipt_long_outlined,
      route: '/easy-mode/transactions',
    ),
    ExtraFeatureConfig(
      feature: ExtraFeature.mobileRecharge,
      nameKey: 'unlock_feature_recharge',
      descriptionKey: 'unlock_desc_recharge',
      proposalMessageKey: 'unlock_proposal_recharge',
      iconData: Icons.phone_android,
      route: '/easy-mode/recharge',
    ),
    ExtraFeatureConfig(
      feature: ExtraFeature.qrPayment,
      nameKey: 'unlock_feature_qr',
      descriptionKey: 'unlock_desc_qr',
      proposalMessageKey: 'unlock_proposal_qr',
      iconData: Icons.qr_code_scanner,
      route: '/easy-mode/qr-payment',
    ),
  ];

  static ExtraFeatureConfig forFeature(ExtraFeature feature) =>
      all.firstWhere((c) => c.feature == feature);
}
