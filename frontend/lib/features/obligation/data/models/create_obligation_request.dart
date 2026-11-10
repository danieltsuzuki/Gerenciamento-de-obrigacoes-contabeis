class CreateObligationRequest {
  final int companyId;
  final int responsibleId;
  final String title;
  final String? description;
  final String dueDate;

  const CreateObligationRequest({
    required this.companyId,
    required this.responsibleId,
    required this.title,
    this.description,
    required this.dueDate,
  });

  Map<String, dynamic> toJson() => {
        'companyId': companyId,
        'responsibleId': responsibleId,
        'title': title,
        if (description != null) 'description': description,
        'dueDate': dueDate,
      };
}

