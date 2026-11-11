package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto.AttachmentResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto.DownloadedFile;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.entity.Attachment;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.exception.InvalidFileException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.mapper.AttachmentMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.repository.AttachmentRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.storage.FileStorage;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.storage.StorageException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.Obligation;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository.ObligationRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Paths;
import java.time.Clock;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Service
@Transactional
public class AttachmentService {

    private static final Logger log = LoggerFactory.getLogger(AttachmentService.class);

    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of(
            "application/pdf",
            "image/png",
            "image/jpeg",
            "image/webp",
            "text/plain",
            "text/csv",
            "application/xml",
            "text/xml",
            "application/zip",
            "application/x-zip-compressed",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    );

    private final AttachmentRepository attachmentRepository;
    private final ObligationRepository obligationRepository;
    private final FileStorage fileStorage;
    private final AttachmentMapper attachmentMapper;
    private final Clock clock;

    public AttachmentService(
            AttachmentRepository attachmentRepository,
            ObligationRepository obligationRepository,
            FileStorage fileStorage,
            AttachmentMapper attachmentMapper,
            Clock clock
    ) {
        this.attachmentRepository = attachmentRepository;
        this.obligationRepository = obligationRepository;
        this.fileStorage = fileStorage;
        this.attachmentMapper = attachmentMapper;
        this.clock = clock;
    }

    public AttachmentResponse upload(Long obligationId, MultipartFile file) {
        if (obligationId == null) {
            throw new NotFoundException("Obrigação", null);
        }

        Obligation obligation = obligationRepository.findById(obligationId)
                .orElseThrow(() -> new NotFoundException("Obrigação", obligationId));

        if (file == null || file.isEmpty()) {
            throw new InvalidFileException("O arquivo não pode ser nulo ou vazio.");
        }

        String rawFilename = file.getOriginalFilename();
        if (rawFilename == null || rawFilename.trim().isBlank()) {
            throw new InvalidFileException("O nome do arquivo é obrigatório.");
        }

        String sanitizedFilename = Paths.get(rawFilename).getFileName().toString().trim();
        if (sanitizedFilename.isBlank()) {
            throw new InvalidFileException("Nome de arquivo inválido.");
        }

        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType.toLowerCase())) {
            throw new InvalidFileException("Tipo de arquivo não permitido: " + contentType);
        }

        String storageKey;
        try {
            storageKey = fileStorage.store(file.getInputStream(), obligationId, sanitizedFilename);
        } catch (IOException e) {
            throw new StorageException("Falha ao ler o fluxo de dados do arquivo.", e);
        }

        try {
            Attachment attachment = new Attachment();
            attachment.setObligation(obligation);
            attachment.setName(sanitizedFilename);
            attachment.setContentType(contentType.toLowerCase());
            attachment.setSize(file.getSize());
            attachment.setStorageKey(storageKey);
            attachment.setUploadedAt(LocalDateTime.now(clock));

            Attachment saved = attachmentRepository.save(attachment);
            log.info("Attachment uploaded: id={}, obligationId={}, fileName='{}', size={} bytes", saved.getId(), obligationId, saved.getName(), saved.getSize());
            return attachmentMapper.toResponse(saved);
        } catch (Exception e) {
            fileStorage.delete(storageKey);
            throw e;
        }
    }

    @Transactional(readOnly = true)
    public List<AttachmentResponse> findByObligationId(Long obligationId) {
        if (obligationId == null || obligationRepository.findById(obligationId).isEmpty()) {
            throw new NotFoundException("Obrigação", obligationId);
        }

        List<Attachment> attachments = attachmentRepository.findByObligationId(obligationId);
        return attachments.stream()
                .map(attachmentMapper::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public DownloadedFile download(Long attachmentId) {
        if (attachmentId == null) {
            throw new NotFoundException("Anexo", null);
        }

        Attachment attachment = attachmentRepository.findById(attachmentId)
                .orElseThrow(() -> new NotFoundException("Anexo", attachmentId));

        Resource resource = fileStorage.load(attachment.getStorageKey());
        Long obligationId = attachment.getObligation() != null ? attachment.getObligation().getId() : null;
        log.info("Attachment downloaded: id={}, obligationId={}, fileName='{}'", attachmentId, obligationId, attachment.getName());
        return new DownloadedFile(
                resource,
                attachment.getName(),
                attachment.getContentType(),
                attachment.getSize()
        );
    }
}
