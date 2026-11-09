package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

@Schema(description = "Dados para criação de obrigação fiscal")
public record CreateObligationRequest(
        @Schema(description = "ID da empresa cliente ativa", example = "1")
        @NotNull(message = "O identificador da empresa é obrigatório.")
        Long companyId,

        @Schema(description = "ID do responsável contábil ativo", example = "1")
        @NotNull(message = "O identificador do responsável é obrigatório.")
        Long responsibleId,

        @Schema(description = "Título da obrigação fiscal", example = "Entrega da DCTF Mensal")
        @NotBlank(message = "O título da obrigação é obrigatório.")
        @Size(max = 255, message = "O título não pode exceder 255 caracteres.")
        String title,

        @Schema(description = "Descrição detalhada dos requisitos da obrigação", example = "Gerar e transmitir a DCTF ref. ao mês anterior.")
        String description,

        @Schema(description = "Data limite de vencimento", example = "2026-11-30")
        @NotNull(message = "O prazo da obrigação é obrigatório.")
        LocalDate dueDate
) {
}
