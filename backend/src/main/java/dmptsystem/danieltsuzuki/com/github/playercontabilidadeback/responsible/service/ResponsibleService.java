package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.CreateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.UpdateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.mapper.ResponsibleMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.DuplicateResourceException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;

@Service
@Transactional
public class ResponsibleService {

    private final ResponsibleRepository responsibleRepository;
    private final ResponsibleMapper responsibleMapper;
    private final PasswordEncoder passwordEncoder;

    public ResponsibleService(
            ResponsibleRepository responsibleRepository,
            ResponsibleMapper responsibleMapper,
            PasswordEncoder passwordEncoder
    ) {
        this.responsibleRepository = responsibleRepository;
        this.responsibleMapper = responsibleMapper;
        this.passwordEncoder = passwordEncoder;
    }

    public ResponsibleResponse create(CreateResponsibleRequest request) {
        String normalizedEmail = normalizeEmail(request.email());

        if (responsibleRepository.existsByEmail(normalizedEmail)) {
            throw new DuplicateResourceException("DUPLICATE_EMAIL", "E-mail já cadastrado para outro responsável.");
        }

        Responsible responsible = responsibleMapper.toEntity(request);
        responsible.setEmail(normalizedEmail);
        responsible.setPasswordHash(passwordEncoder.encode(request.password()));

        Responsible saved = responsibleRepository.save(responsible);
        return responsibleMapper.toResponse(saved);
    }

    @Transactional(readOnly = true)
    public ResponsibleResponse findById(Long id) {
        Responsible responsible = responsibleRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Responsável", id));
        return responsibleMapper.toResponse(responsible);
    }

    @Transactional(readOnly = true)
    public Page<ResponsibleResponse> findAll(Boolean active, Pageable pageable) {
        Page<Responsible> page;
        if (active != null) {
            page = responsibleRepository.findByActive(active, pageable);
        } else {
            page = responsibleRepository.findAll(pageable);
        }
        return page.map(responsibleMapper::toResponse);
    }

    public ResponsibleResponse update(Long id, UpdateResponsibleRequest request) {
        Responsible responsible = responsibleRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Responsável", id));

        String normalizedEmail = normalizeEmail(request.email());

        if (responsibleRepository.existsByEmailAndIdNot(normalizedEmail, id)) {
            throw new DuplicateResourceException("DUPLICATE_EMAIL", "E-mail já cadastrado para outro responsável.");
        }

        responsible.setName(request.name());
        responsible.setEmail(normalizedEmail);
        responsible.setActive(request.active());

        Responsible updated = responsibleRepository.save(responsible);
        return responsibleMapper.toResponse(updated);
    }

    private String normalizeEmail(String raw) {
        return raw == null ? null : raw.trim().toLowerCase(Locale.ROOT);
    }
}

