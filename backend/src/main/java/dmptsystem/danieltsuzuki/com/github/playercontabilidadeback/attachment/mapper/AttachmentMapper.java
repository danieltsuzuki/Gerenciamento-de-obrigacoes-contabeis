package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.mapper;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto.AttachmentResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.entity.Attachment;
import org.springframework.stereotype.Component;

@Component
public class AttachmentMapper {

    public AttachmentResponse toResponse(Attachment attachment) {
        if (attachment == null) {
            return null;
        }
        return new AttachmentResponse(
                attachment.getId(),
                attachment.getObligation() != null ? attachment.getObligation().getId() : null,
                attachment.getName(),
                attachment.getContentType(),
                attachment.getSize(),
                attachment.getUploadedAt()
        );
    }
}

