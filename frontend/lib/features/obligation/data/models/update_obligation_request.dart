import '../../domain/entities/obligation.dart';

class UpdateObligationRequest {
  final int companyId;
  final int responsibleId;
  final String title;
  final String? description;
  final String dueDate;
  final ObligationStatus? status;

  const UpdateObligationRequest({
    required this.companyId,
    required this.responsibleId,
    required this.title,
    this.description,
    required this.dueDate,
    this.status,
  });

  Map<String, dynamic> toJson() => {
        'companyId': companyId,
        'responsibleId': responsibleId,
        'title': title,
        if (description != null) 'description': description,
        'dueDate': dueDate,
        if (status != null) 'status': status!.code,
      };
}
