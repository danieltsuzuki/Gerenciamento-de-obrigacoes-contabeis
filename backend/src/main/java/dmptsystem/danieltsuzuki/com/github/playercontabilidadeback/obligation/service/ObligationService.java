package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.repository.AttachmentRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.repository.CompanyRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.CreateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationDetailResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationListItemResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationWithAttachmentCount;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.UpdateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.Obligation;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.mapper.ObligationMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository.ObligationRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BusinessRuleException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDate;
import java.util.Objects;

@Service
@Transactional
public class ObligationService {

    private final ObligationRepository obligationRepository;
    private final CompanyRepository companyRepository;
    private final ResponsibleRepository responsibleRepository;
    private final AttachmentRepository attachmentRepository;
    private final ObligationMapper obligationMapper;
    private final Clock clock;

    public ObligationService(
            ObligationRepository obligationRepository,
            CompanyRepository companyRepository,
            ResponsibleRepository responsibleRepository,
            AttachmentRepository attachmentRepository,
            ObligationMapper obligationMapper,
            Clock clock
    ) {
        this.obligationRepository = obligationRepository;
        this.companyRepository = companyRepository;
        this.responsibleRepository = responsibleRepository;
        this.attachmentRepository = attachmentRepository;
        this.obligationMapper = obligationMapper;
        this.clock = clock;
    }

    public ObligationDetailResponse create(CreateObligationRequest request) {
        Company company = requireActiveCompany(request.companyId());
        Responsible responsible = requireActiveResponsible(request.responsibleId());

        Obligation obligation = obligationMapper.toEntity(request, company, responsible);
        // O status inicial nasce PENDING por definição da entidade / DDL

        Obligation saved = obligationRepository.save(obligation);
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
            Pageable pageable
    ) {
        Page<ObligationWithAttachmentCount> page = obligationRepository.findWithAttachmentCountByFilters(
                companyId,
                responsibleId,
                status,
                dueFrom,
                dueTo,
                pageable
        );
        return page.map(obligationMapper::toListItemResponse);
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

        // Transição de status RN-008
        if (request.status() != null && request.status() != obligation.getStatus()) {
            obligation.changeStatus(request.status(), clock);
        }

        obligation.setTitle(request.title().trim());
        obligation.setDescription(request.description() != null ? request.description().trim() : null);
        obligation.setDueDate(request.dueDate());

        Obligation updated = obligationRepository.save(obligation);
        long count = attachmentRepository.countByObligationId(id);
        return obligationMapper.toDetailResponse(updated, count);
    }

    public ObligationDetailResponse updateStatus(Long id, ObligationStatus newStatus) {
        Obligation obligation = obligationRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Obrigação", id));

        obligation.changeStatus(newStatus, clock);

        Obligation updated = obligationRepository.save(obligation);
        long count = attachmentRepository.countByObligationId(id);
        return obligationMapper.toDetailResponse(updated, count);
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
