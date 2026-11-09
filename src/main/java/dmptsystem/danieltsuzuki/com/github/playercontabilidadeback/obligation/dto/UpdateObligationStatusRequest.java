package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import jakarta.validation.constraints.NotNull;

public record UpdateObligationStatusRequest(
        @NotNull(message = "O novo status é obrigatório.")
        ObligationStatus status
) {
}

