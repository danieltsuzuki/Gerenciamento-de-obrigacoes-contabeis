enum ObligationStatus {
  pending('PENDING', 'Pendente'),
  inProgress('IN_PROGRESS', 'Em Andamento'),
  completed('COMPLETED', 'Concluída');

  final String code;
  final String label;

  const ObligationStatus(this.code, this.label);

  static ObligationStatus fromCode(String? code) {
    switch (code) {
      case 'IN_PROGRESS':
        return ObligationStatus.inProgress;
      case 'COMPLETED':
        return ObligationStatus.completed;
      case 'PENDING':
      default:
        return ObligationStatus.pending;
    }
  }

  bool canTransitionTo(ObligationStatus target) {
    switch (this) {
      case ObligationStatus.pending:
        return target == ObligationStatus.inProgress;
      case ObligationStatus.inProgress:
        return target == ObligationStatus.completed;
      case ObligationStatus.completed:
        return false;
    }
  }
}

class ObligationParticipantSummary {
  final int id;
  final String name;

  const ObligationParticipantSummary({
    required this.id,
    required this.name,
  });

  factory ObligationParticipantSummary.fromJson(Map<String, dynamic> json) {
    return ObligationParticipantSummary(
      id: (json['id'] as num).toInt(),
      name: (json['legalName'] ?? json['name'] ?? '') as String,
    );
  }
}

class Obligation {
  final int id;
  final String title;
  final String? description;
  final ObligationStatus status;
  final DateTime dueDate;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ObligationParticipantSummary company;
  final ObligationParticipantSummary responsible;
  final int attachmentCount;

  const Obligation({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.dueDate,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
    required this.company,
    required this.responsible,
    this.attachmentCount = 0,
  });

  factory Obligation.fromJson(Map<String, dynamic> json) {
    return Obligation(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String?,
      status: ObligationStatus.fromCode(json['status'] as String?),
      dueDate: DateTime.parse(json['dueDate'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      company: json['company'] != null
          ? ObligationParticipantSummary.fromJson(
              json['company'] as Map<String, dynamic>,
            )
          : ObligationParticipantSummary(
              id: ((json['companyId'] as num?) ?? 0).toInt(),
              name: '',
            ),
      responsible: json['responsible'] != null
          ? ObligationParticipantSummary.fromJson(
              json['responsible'] as Map<String, dynamic>,
            )
          : ObligationParticipantSummary(
              id: ((json['responsibleId'] as num?) ?? 0).toInt(),
              name: '',
            ),
      attachmentCount: ((json['attachmentCount'] as num?) ?? 0).toInt(),
    );
  }

  bool get isOverdue {
    if (status == ObligationStatus.completed) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dueDate.isBefore(today);
  }

  Obligation copyWith({
    int? id,
    String? title,
    String? description,
    ObligationStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    ObligationParticipantSummary? company,
    ObligationParticipantSummary? responsible,
    int? attachmentCount,
  }) {
    return Obligation(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      company: company ?? this.company,
      responsible: responsible ?? this.responsible,
      attachmentCount: attachmentCount ?? this.attachmentCount,
    );
  }
}
