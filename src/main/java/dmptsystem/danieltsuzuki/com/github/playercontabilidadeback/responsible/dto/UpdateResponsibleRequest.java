package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Schema(description = "Dados para atualização de responsável")
public record UpdateResponsibleRequest(
        @Schema(description = "Nome completo do responsável", example = "Maria Silva Santos")
        @NotBlank(message = "Nome é obrigatório")
        @Size(max = 255, message = "Nome deve ter no máximo 255 caracteres")
        String name,

        @Schema(description = "E-mail do responsável", example = "maria.santos@empresa.com")
        @NotBlank(message = "E-mail é obrigatório")
        @Email(message = "Formato de e-mail inválido")
        @Size(max = 255, message = "E-mail deve ter no máximo 255 caracteres")
        String email,

        @Schema(description = "Situação cadastral (soft delete via inativação)", example = "true")
        @NotNull(message = "Situação é obrigatória")
        Boolean active
) {
}
