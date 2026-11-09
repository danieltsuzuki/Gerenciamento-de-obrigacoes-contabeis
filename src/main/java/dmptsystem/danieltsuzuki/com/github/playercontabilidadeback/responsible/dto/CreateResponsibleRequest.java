package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Dados para cadastro de novo responsável contábil")
public record CreateResponsibleRequest(
        @Schema(description = "Nome completo do responsável", example = "Maria Silva")
        @NotBlank(message = "Nome é obrigatório")
        @Size(max = 255, message = "Nome deve ter no máximo 255 caracteres")
        String name,

        @Schema(description = "E-mail único do responsável", example = "maria.silva@empresa.com")
        @NotBlank(message = "E-mail é obrigatório")
        @Email(message = "Formato de e-mail inválido")
        @Size(max = 255, message = "E-mail deve ter no máximo 255 caracteres")
        String email,

        @Schema(description = "Senha do responsável (mínimo de 6 caracteres)", example = "SenhaSegura@123")
        @NotBlank(message = "Senha é obrigatória")
        @Size(min = 6, max = 100, message = "Senha deve ter entre 6 e 100 caracteres")
        String password,

        @Schema(description = "Indica se o responsável já inicia ativo (padrão true)", example = "true")
        Boolean active
) {
}
