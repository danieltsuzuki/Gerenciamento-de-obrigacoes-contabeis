package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.mapper;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanyResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CreateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.UpdateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import org.springframework.stereotype.Component;

@Component
public class CompanyMapper {

    public Company toEntity(CreateCompanyRequest request) {
        if (request == null) {
            return null;
        }
        Company company = new Company();
        company.setLegalName(request.legalName());
        company.setTradeName(request.tradeName());
        company.setCnpj(request.cnpj());
        if (request.active() != null) {
            company.setActive(request.active());
        }
        return company;
    }

    public void updateEntity(UpdateCompanyRequest request, Company company) {
        if (request == null || company == null) {
            return;
        }
        company.setLegalName(request.legalName());
        company.setTradeName(request.tradeName());
        company.setCnpj(request.cnpj());
        company.setActive(request.active());
    }

    public CompanyResponse toResponse(Company company) {
        if (company == null) {
            return null;
        }
        return new CompanyResponse(
                company.getId(),
                company.getLegalName(),
                company.getTradeName(),
                company.getCnpj(),
                company.isActive(),
                company.getCreatedAt(),
                company.getUpdatedAt()
        );
    }
}
