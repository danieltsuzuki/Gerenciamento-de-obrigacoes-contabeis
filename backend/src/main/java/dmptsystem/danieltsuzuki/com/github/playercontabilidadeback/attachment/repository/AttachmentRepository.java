package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.repository;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.entity.Attachment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.Repository;

import java.util.List;
import java.util.Optional;

public interface AttachmentRepository extends Repository<Attachment, Long> {

    Attachment save(Attachment attachment);

    Optional<Attachment> findById(Long id);

    Page<Attachment> findAll(Pageable pageable);

    List<Attachment> findByObligationId(Long obligationId);

    long countByObligationId(Long obligationId);
}
