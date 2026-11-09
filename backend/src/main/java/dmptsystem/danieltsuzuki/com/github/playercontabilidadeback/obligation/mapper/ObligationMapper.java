package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.mapper;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanySummaryResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.CreateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationDetailResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationListItemResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationWithAttachmentCount;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.Obligation;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleSummaryResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import org.springframework.stereotype.Component;

@Component
public class ObligationMapper {

    public Obligation toEntity(CreateObligationRequest request, Company company, Responsible responsible) {
        Obligation obligation = new Obligation();
        obligation.setCompany(company);
        obligation.setResponsible(responsible);
        obligation.setTitle(request.title() != null ? request.title().trim() : null);
        obligation.setDescription(request.description() != null ? request.description().trim() : null);
        obligation.setDueDate(request.dueDate());
        return obligation;
    }

    public CompanySummaryResponse toCompanySummary(Company company) {
        if (company == null) {
            return null;
        }
        return new CompanySummaryResponse(
                company.getId(),
                company.getLegalName(),
                company.getTradeName(),
                company.getCnpj(),
                company.isActive()
        );
    }

    public ResponsibleSummaryResponse toResponsibleSummary(Responsible responsible) {
        if (responsible == null) {
            return null;
        }
        return new ResponsibleSummaryResponse(
                responsible.getId(),
                responsible.getName(),
                responsible.getEmail(),
                responsible.isActive()
        );
    }

    public ObligationListItemResponse toListItemResponse(ObligationWithAttachmentCount projection) {
        Obligation obligation = projection.obligation();
        return new ObligationListItemResponse(
                obligation.getId(),
                toCompanySummary(obligation.getCompany()),
                toResponsibleSummary(obligation.getResponsible()),
                obligation.getTitle(),
                obligation.getStatus(),
                obligation.getDueDate(),
                projection.attachmentCount(),
                obligation.getCreatedAt(),
                obligation.getCompletedAt()
        );
    }

    public ObligationDetailResponse toDetailResponse(Obligation obligation, long attachmentCount) {
        return new ObligationDetailResponse(
                obligation.getId(),
                toCompanySummary(obligation.getCompany()),
                toResponsibleSummary(obligation.getResponsible()),
                obligation.getTitle(),
                obligation.getDescription(),
                obligation.getStatus(),
                obligation.getDueDate(),
                attachmentCount,
                obligation.getCompletedAt(),
                obligation.getCreatedAt(),
                obligation.getUpdatedAt()
        );
    }
}
