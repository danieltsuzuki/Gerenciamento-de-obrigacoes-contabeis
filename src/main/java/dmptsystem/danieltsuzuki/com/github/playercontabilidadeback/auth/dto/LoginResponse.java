package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;

public record LoginResponse(
        String token,
        String tokenType,
        long expiresIn,
        ResponsibleResponse user
) {
}

