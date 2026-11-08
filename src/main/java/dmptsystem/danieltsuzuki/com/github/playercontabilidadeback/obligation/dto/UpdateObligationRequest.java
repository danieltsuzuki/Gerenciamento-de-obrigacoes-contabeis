package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record UpdateObligationRequest(
        @NotNull(message = "O identificador da empresa é obrigatório.")
        Long companyId,

        @NotNull(message = "O identificador do responsável é obrigatório.")
        Long responsibleId,

        @NotBlank(message = "O título da obrigação é obrigatório.")
        @Size(max = 255, message = "O título não pode exceder 255 caracteres.")
        String title,

        String description,

        @NotNull(message = "O prazo da obrigação é obrigatório.")
        LocalDate dueDate,

        ObligationStatus status
) {
}

