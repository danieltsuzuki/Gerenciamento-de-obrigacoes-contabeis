package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto;

import java.time.LocalDateTime;

public record CompanyResponse(
        Long id,
        String legalName,
        String tradeName,
        String cnpj,
        boolean active,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}

