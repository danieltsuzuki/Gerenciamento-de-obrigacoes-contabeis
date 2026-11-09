package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;

@Schema(description = "Requisição para transição de status na máquina de estados")
public record UpdateObligationStatusRequest(
        @Schema(description = "Novo status desejado (Transições permitidas: PENDING -> IN_PROGRESS -> COMPLETED)", example = "IN_PROGRESS")
        @NotNull(message = "O novo status é obrigatório.")
        ObligationStatus status
) {
}
