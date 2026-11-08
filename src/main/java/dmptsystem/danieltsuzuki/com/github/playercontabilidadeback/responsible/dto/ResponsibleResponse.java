package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto;

import java.time.LocalDateTime;

public record ResponsibleResponse(
        Long id,
        String name,
        String email,
        boolean active,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}

