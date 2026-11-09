package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import io.swagger.v3.oas.annotations.media.Schema;

@Schema(description = "Resposta de autenticação bem-sucedida")
public record LoginResponse(
        @Schema(description = "Token de acesso JWT para autenticação Bearer", example = "eyJhbGciOiJIUzI1NiJ9...")
        String token,

        @Schema(description = "Tipo de token", example = "Bearer")
        String tokenType,

        @Schema(description = "Tempo de expiração do token em milissegundos", example = "1800000")
        long expiresIn,

        @Schema(description = "Dados resumidos do responsável autenticado")
        ResponsibleResponse user
) {
}

