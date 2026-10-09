import 'package:impulsa_reto_3_nadie_fuera/features/gradual_unlock/domain/entities/extra_feature.dart';
import 'package:meta/meta.dart';

@immutable
class UnlockProposal {
  const UnlockProposal({required this.feature});

  final ExtraFeature feature;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnlockProposal && other.feature == feature;

  @override
  int get hashCode => feature.hashCode;
}
