package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "Dados detalhados do responsável")
public record ResponsibleResponse(
        @Schema(description = "Identificador único do responsável", example = "1")
        Long id,

        @Schema(description = "Nome do responsável", example = "Maria Silva")
        String name,

        @Schema(description = "E-mail do responsável", example = "maria.silva@empresa.com")
        String email,

        @Schema(description = "Indica se o responsável está ativo", example = "true")
        boolean active,

        @Schema(description = "Data e hora de criação do registro", example = "2026-11-09T00:00:00")
        LocalDateTime createdAt,

        @Schema(description = "Data e hora da última atualização", example = "2026-11-09T00:00:00")
        LocalDateTime updatedAt
) {
}
