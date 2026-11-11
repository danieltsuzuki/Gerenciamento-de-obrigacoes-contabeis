package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.repository.AttachmentRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.repository.CompanyRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.CreateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationDetailResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationListItemResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationStatusHistoryResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationWithAttachmentCount;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.UpdateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.Obligation;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.ObligationStatusHistory;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.mapper.ObligationMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository.ObligationRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository.ObligationStatusHistoryRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BusinessRuleException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.security.SecurityAuditorAware;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.security.UserPrincipal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;

@Service
@Transactional
public class ObligationService {

    private static final Logger log = LoggerFactory.getLogger(ObligationService.class);

    private final ObligationRepository obligationRepository;
    private final ObligationStatusHistoryRepository statusHistoryRepository;
    private final CompanyRepository companyRepository;
    private final ResponsibleRepository responsibleRepository;
    private final AttachmentRepository attachmentRepository;
    private final ObligationMapper obligationMapper;
    private final SecurityAuditorAware securityAuditorAware;
    private final Clock clock;

    public ObligationService(
            ObligationRepository obligationRepository,
            ObligationStatusHistoryRepository statusHistoryRepository,
            CompanyRepository companyRepository,
            ResponsibleRepository responsibleRepository,
            AttachmentRepository attachmentRepository,
            ObligationMapper obligationMapper,
            SecurityAuditorAware securityAuditorAware,
            Clock clock
    ) {
        this.obligationRepository = obligationRepository;
        this.statusHistoryRepository = statusHistoryRepository;
        this.companyRepository = companyRepository;
        this.responsibleRepository = responsibleRepository;
        this.attachmentRepository = attachmentRepository;
        this.obligationMapper = obligationMapper;
        this.securityAuditorAware = securityAuditorAware;
        this.clock = clock;
    }

    public ObligationDetailResponse create(CreateObligationRequest request) {
        Company company = requireActiveCompany(request.companyId());
        Responsible responsible = requireActiveResponsible(request.responsibleId());

        Obligation obligation = obligationMapper.toEntity(request, company, responsible);
        // O status inicial nasce PENDING por definição da entidade / DDL

        Obligation saved = obligationRepository.save(obligation);

        Responsible auditor = securityAuditorAware.getCurrentAuditor().orElse(null);
        statusHistoryRepository.save(new ObligationStatusHistory(saved, null, ObligationStatus.PENDING, auditor));

        log.info("Obligation created: id={}, title='{}', companyId={}, responsibleId={}",
                saved.getId(), saved.getTitle(), company.getId(), responsible.getId());

        return obligationMapper.toDetailResponse(saved, 0L);
    }

    @Transactional(readOnly = true)
    public ObligationDetailResponse findById(Long id) {
        Obligation obligation = obligationRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Obrigação", id));
        long count = attachmentRepository.countByObligationId(id);
        return obligationMapper.toDetailResponse(obligation, count);
    }

    @Transactional(readOnly = true)
    public Page<ObligationListItemResponse> findAll(
            Long companyId,
            Long responsibleId,
            ObligationStatus status,
            LocalDate dueFrom,
            LocalDate dueTo,
            String q,
            Pageable pageable
    ) {
        if (q != null && q.trim().length() > 100) {
            throw new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.SearchQueryTooLongException(
                    "O parâmetro de busca 'q' não pode exceder 100 caracteres."
            );
        }
        String cleanQ = (q != null && !q.trim().isEmpty()) ? q.trim() : null;

        Page<ObligationWithAttachmentCount> page = obligationRepository.findWithAttachmentCountByFilters(
                companyId,
                responsibleId,
                status,
                dueFrom,
                dueTo,
                cleanQ,
                pageable
        );
        return page.map(obligationMapper::toListItemResponse);
    }

    @Transactional(readOnly = true)
    public Page<ObligationListItemResponse> findAll(
            Long companyId,
            Long responsibleId,
            ObligationStatus status,
            LocalDate dueFrom,
            LocalDate dueTo,
            Pageable pageable
    ) {
        return findAll(companyId, responsibleId, status, dueFrom, dueTo, null, pageable);
    }

    public ObligationDetailResponse update(Long id, UpdateObligationRequest request) {
        Obligation obligation = obligationRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Obrigação", id));

        // Validação defensiva RN-006: só valida se o ID mudou
        if (!Objects.equals(obligation.getCompany().getId(), request.companyId())) {
            Company newCompany = requireActiveCompany(request.companyId());
            obligation.setCompany(newCompany);
        }

        if (!Objects.equals(obligation.getResponsible().getId(), request.responsibleId())) {
            Responsible newResponsible = requireActiveResponsible(request.responsibleId());
            obligation.setResponsible(newResponsible);
        }

        // Transição de status RN-008 & SPEC-041
        ObligationStatus previousStatus = obligation.getStatus();
        boolean statusChanged = false;
        if (request.status() != null && request.status() != previousStatus) {
            checkResponsibleAuthorization(obligation);
            obligation.changeStatus(request.status(), clock);
            statusChanged = true;
        }

        obligation.setTitle(request.title().trim());
        obligation.setDescription(request.description() != null ? request.description().trim() : null);
        obligation.setDueDate(request.dueDate());

        Obligation updated = obligationRepository.save(obligation);

        if (statusChanged) {
            Responsible auditor = securityAuditorAware.getCurrentAuditor().orElse(null);
            statusHistoryRepository.save(new ObligationStatusHistory(updated, previousStatus, request.status(), auditor));
            log.info("Obligation status transitioned via update: id={}, from={}, to={}",
                    updated.getId(), previousStatus, request.status());
        }

        log.info("Obligation updated: id={}, title='{}'", updated.getId(), updated.getTitle());
        long count = attachmentRepository.countByObligationId(id);
        return obligationMapper.toDetailResponse(updated, count);
    }

    public ObligationDetailResponse updateStatus(Long id, ObligationStatus newStatus) {
        Obligation obligation = obligationRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Obrigação", id));

        checkResponsibleAuthorization(obligation);

        ObligationStatus previousStatus = obligation.getStatus();
        obligation.changeStatus(newStatus, clock);

        Obligation updated = obligationRepository.save(obligation);

        Responsible auditor = securityAuditorAware.getCurrentAuditor().orElse(null);
        statusHistoryRepository.save(new ObligationStatusHistory(updated, previousStatus, newStatus, auditor));
        log.info("Obligation status transitioned: id={}, from={}, to={}",
                updated.getId(), previousStatus, newStatus);

        long count = attachmentRepository.countByObligationId(id);
        return obligationMapper.toDetailResponse(updated, count);
    }

    private void checkResponsibleAuthorization(Obligation obligation) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || authentication instanceof AnonymousAuthenticationToken) {
            throw new AccessDeniedException("Apenas o usuário responsável atribuído pode avançar o status desta obrigação.");
        }
        Object principal = authentication.getPrincipal();
        if (principal instanceof UserPrincipal userPrincipal) {
            Long currentUserId = userPrincipal.getId();
            if (currentUserId == null || !Objects.equals(currentUserId, obligation.getResponsible().getId())) {
                throw new AccessDeniedException("Apenas o usuário responsável atribuído pode avançar o status desta obrigação.");
            }
        } else {
            throw new AccessDeniedException("Apenas o usuário responsável atribuído pode avançar o status desta obrigação.");
        }
    }

    @Transactional(readOnly = true)
    public List<ObligationStatusHistoryResponse> findHistoryByObligationId(Long obligationId) {
        if (obligationId == null || obligationRepository.findById(obligationId).isEmpty()) {
            throw new NotFoundException("Obrigação", obligationId);
        }

        return statusHistoryRepository.findByObligationIdOrderByChangedAtAscIdAsc(obligationId)
                .stream()
                .map(ObligationStatusHistoryResponse::fromEntity)
                .toList();
    }

    private Company requireActiveCompany(Long companyId) {
        Company company = companyRepository.findById(companyId)
                .orElseThrow(() -> new NotFoundException("Empresa", companyId));
        if (!company.isActive()) {
            throw new BusinessRuleException("COMPANY_INACTIVE", "Empresa inativa não pode receber novas obrigações.");
        }
        return company;
    }

    private Responsible requireActiveResponsible(Long responsibleId) {
        Responsible responsible = responsibleRepository.findById(responsibleId)
                .orElseThrow(() -> new NotFoundException("Responsável", responsibleId));
        if (!responsible.isActive()) {
            throw new BusinessRuleException("USER_INACTIVE", "Usuário inativo não pode receber novas atribuições.");
        }
        return responsible;
    }
}
