package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanySummaryResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleSummaryResponse;
import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Schema(description = "Detalhes completos da obrigação fiscal")
public record ObligationDetailResponse(
        @Schema(description = "Identificador único da obrigação", example = "1")
        Long id,

        @Schema(description = "Dados resumidos da empresa associada")
        CompanySummaryResponse company,

        @Schema(description = "Dados resumidos do responsável contábil")
        ResponsibleSummaryResponse responsible,

        @Schema(description = "Título da obrigação", example = "Entrega da DCTF Mensal")
        String title,

        @Schema(description = "Descrição detalhada", example = "Transmitir DCTF do mês anterior")
        String description,

        @Schema(description = "Status atual no ciclo de vida (PENDING, IN_PROGRESS, COMPLETED)", example = "PENDING")
        ObligationStatus status,

        @Schema(description = "Data limite de vencimento", example = "2026-11-30")
        LocalDate dueDate,

        @Schema(description = "Quantidade de arquivos anexados à obrigação", example = "2")
        long attachmentCount,

        @Schema(description = "Data e hora de conclusão (preenchido apenas quando status for COMPLETED)", example = "2026-11-09T00:00:00")
        LocalDateTime completedAt,

        @Schema(description = "Data e hora de criação do registro", example = "2026-11-09T00:00:00")
        LocalDateTime createdAt,

        @Schema(description = "Data e hora da última alteração", example = "2026-11-09T00:00:00")
        LocalDateTime updatedAt
) {
}
