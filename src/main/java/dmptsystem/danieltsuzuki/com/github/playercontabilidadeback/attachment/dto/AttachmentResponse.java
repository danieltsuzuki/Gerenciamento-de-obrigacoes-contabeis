package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto;

import java.time.LocalDateTime;

public record AttachmentResponse(
        Long id,
        Long obligationId,
        String name,
        String contentType,
        Long size,
        LocalDateTime uploadedAt
) {
}

