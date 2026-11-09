package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

@Schema(description = "Dados para autenticação de responsável")
public record LoginRequest(
        @Schema(description = "E-mail cadastrado do responsável", example = "maria.silva@empresa.com")
        @NotBlank(message = "O e-mail é obrigatório.")
        @Email(message = "O e-mail deve ter formato válido.")
        String email,

        @Schema(description = "Senha do responsável", example = "SenhaForte@123")
        @NotBlank(message = "A senha é obrigatória.")
        String password
) {
}

