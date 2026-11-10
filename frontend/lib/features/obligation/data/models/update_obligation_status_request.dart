import '../../domain/entities/obligation.dart';

class UpdateObligationStatusRequest {
  final ObligationStatus status;

  const UpdateObligationStatusRequest(this.status);

  Map<String, dynamic> toJson() => {
        'status': status.code,
      };
}
