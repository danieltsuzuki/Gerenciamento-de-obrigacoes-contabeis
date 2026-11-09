package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto;

import org.springframework.core.io.Resource;

public record DownloadedFile(
        Resource resource,
        String originalFilename,
        String contentType,
        long size
) {
}

