package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto;

import io.swagger.v3.oas.annotations.media.Schema;

import java.time.LocalDateTime;

@Schema(description = "Metadados do arquivo anexo")
public record AttachmentResponse(
        @Schema(description = "Identificador único do anexo", example = "1")
        Long id,

        @Schema(description = "Identificador da obrigação vinculada", example = "10")
        Long obligationId,

        @Schema(description = "Nome original do arquivo enviado pelo usuário", example = "comprovante_dctf.pdf")
        String name,

        @Schema(description = "Tipo MIME do conteúdo", example = "application/pdf")
        String contentType,

        @Schema(description = "Tamanho do arquivo em bytes", example = "204850")
        Long size,

        @Schema(description = "Data e hora de envio do anexo", example = "2026-11-09T00:00:00")
        LocalDateTime uploadedAt
) {
}
