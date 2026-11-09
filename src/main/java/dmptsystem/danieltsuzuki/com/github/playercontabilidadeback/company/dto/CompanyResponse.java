package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "Dados detalhados da empresa")
public record CompanyResponse(
        @Schema(description = "Identificador único da empresa", example = "1")
        Long id,

        @Schema(description = "Razão social da empresa", example = "Alpha Contabilidade Ltda")
        String legalName,

        @Schema(description = "Nome fantasia", example = "Alpha Tech")
        String tradeName,

        @Schema(description = "CNPJ normalizado (somente dígitos)", example = "12345678000195")
        String cnpj,

        @Schema(description = "Indica se a empresa está ativa no sistema", example = "true")
        boolean active,

        @Schema(description = "Data e hora de criação do registro", example = "2026-11-09T00:00:00")
        LocalDateTime createdAt,

        @Schema(description = "Data e hora da última atualização", example = "2026-11-09T00:00:00")
        LocalDateTime updatedAt
) {
}
