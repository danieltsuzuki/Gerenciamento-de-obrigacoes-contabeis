package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        @NotBlank(message = "O e-mail é obrigatório.")
        @Email(message = "O e-mail deve ter formato válido.")
        String email,

        @NotBlank(message = "A senha é obrigatória.")
        String password
) {
}

