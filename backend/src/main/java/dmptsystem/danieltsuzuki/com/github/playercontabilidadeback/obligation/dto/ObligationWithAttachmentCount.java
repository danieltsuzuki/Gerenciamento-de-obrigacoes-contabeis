package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.Obligation;

public record ObligationWithAttachmentCount(
        Obligation obligation,
        long attachmentCount
) {
}

