package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanySummaryResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Schema(description = "Item resumido de obrigação para listagens")
public record ObligationListItemResponse(
        @Schema(description = "Identificador único da obrigação", example = "1")
        Long id,

        @Schema(description = "Dados resumidos da empresa")
        CompanySummaryResponse company,

        @Schema(description = "Dados resumidos do responsável")
        ResponsibleSummaryResponse responsible,

        @Schema(description = "Título da obrigação", example = "Entrega da DCTF Mensal")
        String title,

        @Schema(description = "Status atual", example = "PENDING")
        ObligationStatus status,

        @Schema(description = "Data limite de vencimento", example = "2026-11-30")
        LocalDate dueDate,

        @Schema(description = "Quantidade de anexos associados", example = "1")
        long attachmentCount,

        @Schema(description = "Data de criação do registro", example = "2026-11-09T00:00:00")
        LocalDateTime createdAt,

        @Schema(description = "Data de conclusão", example = "2026-11-09T00:00:00")
        LocalDateTime completedAt
) {
}
