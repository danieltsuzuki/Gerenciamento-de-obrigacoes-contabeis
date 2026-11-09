package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

@Schema(description = "Dados para atualização de obrigação fiscal")
public record UpdateObligationRequest(
        @Schema(description = "ID da empresa cliente", example = "1")
        @NotNull(message = "O identificador da empresa é obrigatório.")
        Long companyId,

        @Schema(description = "ID do responsável contábil", example = "1")
        @NotNull(message = "O identificador do responsável é obrigatório.")
        Long responsibleId,

        @Schema(description = "Título da obrigação", example = "Entrega da DCTF Mensal")
        @NotBlank(message = "O título da obrigação é obrigatório.")
        @Size(max = 255, message = "O título não pode exceder 255 caracteres.")
        String title,

        @Schema(description = "Descrição detalhada", example = "Gerar e transmitir DCTF consolidada")
        String description,

        @Schema(description = "Data limite de vencimento", example = "2026-11-30")
        @NotNull(message = "O prazo da obrigação é obrigatório.")
        LocalDate dueDate,

        @Schema(description = "Status opcional da obrigação (a máquina de estados também pode ser acionada via PATCH /status)", example = "IN_PROGRESS")
        ObligationStatus status
) {
}
