package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto;

public record CompanySummaryResponse(
        Long id,
        String legalName,
        String tradeName,
        String cnpj,
        boolean active
) {
}

