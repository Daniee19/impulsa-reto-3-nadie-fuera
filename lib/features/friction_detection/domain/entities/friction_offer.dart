import 'package:impulsa_reto_3_nadie_fuera/features/friction_detection/domain/entities/friction_signal.dart';
import 'package:meta/meta.dart';

/// Status of the help offer overlay.
enum FrictionOfferStatus {
  /// Not shown.
  hidden,

  /// Currently visible.
  showing,

  /// User dismissed it.
  dismissed,

  /// User chose "explain".
  acceptedExplain,

  /// User chose "talk to someone".
  acceptedHuman,
}

/// State of the friction help offer.
@immutable
class FrictionOffer {
  /// Creates a friction offer.
  const FrictionOffer({this.signal, this.status = FrictionOfferStatus.hidden});

  /// Creates a hidden offer.
  const FrictionOffer.hidden()
    : signal = null,
      status = FrictionOfferStatus.hidden;

  /// Creates a showing offer.
  FrictionOffer.showing(FrictionSignal this.signal)
    : status = FrictionOfferStatus.showing;

  /// The friction signal that triggered this offer.
  final FrictionSignal? signal;

  /// Current status.
  final FrictionOfferStatus status;

  /// Returns a copy with updated status.
  FrictionOffer copyWith({FrictionOfferStatus? status}) {
    return FrictionOffer(signal: signal, status: status ?? this.status);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrictionOffer &&
          signal == other.signal &&
          status == other.status;

  @override
  int get hashCode => Object.hash(signal, status);
}
