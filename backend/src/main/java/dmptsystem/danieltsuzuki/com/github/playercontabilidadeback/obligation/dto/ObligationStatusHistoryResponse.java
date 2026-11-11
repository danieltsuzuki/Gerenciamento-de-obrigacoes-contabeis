package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.ObligationStatusHistory;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "Registro de transição de status no histórico da obrigação")
public record ObligationStatusHistoryResponse(
        @Schema(description = "Identificador único do evento de histórico", example = "1")
        Long id,

        @Schema(description = "Identificador da obrigação", example = "10")
        Long obligationId,

        @Schema(description = "Status anterior (null na criação)", example = "PENDING")
        ObligationStatus fromStatus,

        @Schema(description = "Novo status da transição", example = "IN_PROGRESS")
        ObligationStatus toStatus,

        @Schema(description = "Usuário responsável que realizou a alteração")
        ResponsibleSummaryResponse changedBy,

        @Schema(description = "Data e hora em que a transição foi registrada", example = "2026-11-11T12:00:00")
        LocalDateTime changedAt
) {
    public static ObligationStatusHistoryResponse fromEntity(ObligationStatusHistory history) {
        ResponsibleSummaryResponse changedByDto = history.getChangedBy() != null
                ? new ResponsibleSummaryResponse(
                history.getChangedBy().getId(),
                history.getChangedBy().getName(),
                history.getChangedBy().getEmail(),
                history.getChangedBy().isActive()
        )
                : null;

        return new ObligationStatusHistoryResponse(
                history.getId(),
                history.getObligation().getId(),
                history.getFromStatus(),
                history.getToStatus(),
                changedByDto,
                history.getChangedAt()
        );
    }
}

