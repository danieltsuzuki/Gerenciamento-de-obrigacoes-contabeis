import 'obligation.dart';

class ChangedBySummary {
  final int id;
  final String name;
  final String email;

  const ChangedBySummary({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ChangedBySummary.fromJson(Map<String, dynamic> json) {
    return ChangedBySummary(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
    );
  }
}

class ObligationStatusHistory {
  final int id;
  final int obligationId;
  final ObligationStatus? fromStatus;
  final ObligationStatus toStatus;
  final ChangedBySummary? changedBy;
  final DateTime changedAt;

  const ObligationStatusHistory({
    required this.id,
    required this.obligationId,
    this.fromStatus,
    required this.toStatus,
    this.changedBy,
    required this.changedAt,
  });

  factory ObligationStatusHistory.fromJson(Map<String, dynamic> json) {
    return ObligationStatusHistory(
      id: (json['id'] as num).toInt(),
      obligationId: (json['obligationId'] as num).toInt(),
      fromStatus: json['fromStatus'] != null
          ? ObligationStatus.fromCode(json['fromStatus'] as String?)
          : null,
      toStatus: ObligationStatus.fromCode(json['toStatus'] as String?),
      changedBy: json['changedBy'] != null
          ? ChangedBySummary.fromJson(json['changedBy'] as Map<String, dynamic>)
          : null,
      changedAt: DateTime.parse(json['changedAt'] as String),
    );
  }
}

