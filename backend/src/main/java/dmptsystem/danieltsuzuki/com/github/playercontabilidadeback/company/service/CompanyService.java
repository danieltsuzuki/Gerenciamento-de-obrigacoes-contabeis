package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanyResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CreateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.UpdateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.mapper.CompanyMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.repository.CompanyRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.DuplicateResourceException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.validator.Cnpj;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class CompanyService {

    private final CompanyRepository companyRepository;
    private final CompanyMapper companyMapper;

    public CompanyService(CompanyRepository companyRepository, CompanyMapper companyMapper) {
        this.companyRepository = companyRepository;
        this.companyMapper = companyMapper;
    }

    public CompanyResponse create(CreateCompanyRequest request) {
        String normalizedCnpj = Cnpj.normalize(request.cnpj());
        if (!Cnpj.isValid(normalizedCnpj)) {
            throw new IllegalArgumentException("CNPJ inválido.");
        }

        if (companyRepository.existsByCnpj(normalizedCnpj)) {
            throw new DuplicateResourceException("DUPLICATE_CNPJ", "CNPJ já cadastrado para outra empresa.");
        }

        Company company = companyMapper.toEntity(request);
        company.setCnpj(normalizedCnpj);
        Company saved = companyRepository.save(company);
        return companyMapper.toResponse(saved);
    }

    @Transactional(readOnly = true)
    public CompanyResponse findById(Long id) {
        Company company = companyRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Empresa", id));
        return companyMapper.toResponse(company);
    }

    @Transactional(readOnly = true)
    public Page<CompanyResponse> findAll(Boolean active, String q, Pageable pageable) {
        if (q != null && q.trim().length() > 100) {
            throw new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.SearchQueryTooLongException(
                    "O parâmetro de busca 'q' não pode exceder 100 caracteres."
            );
        }
        String cleanQ = (q != null && !q.trim().isEmpty()) ? q.trim() : null;

        Page<Company> page;
        if (cleanQ != null) {
            String cleanCnpj = cleanQ.replaceAll("\\D", "");
            page = companyRepository.search(active, cleanQ, cleanCnpj, pageable);
        } else if (active != null) {
            page = companyRepository.findByActive(active, pageable);
        } else {
            page = companyRepository.findAll(pageable);
        }
        return page.map(companyMapper::toResponse);
    }

    @Transactional(readOnly = true)
    public Page<CompanyResponse> findAll(Boolean active, Pageable pageable) {
        return findAll(active, null, pageable);
    }

    public CompanyResponse update(Long id, UpdateCompanyRequest request) {
        Company company = companyRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Empresa", id));

        String normalizedCnpj = Cnpj.normalize(request.cnpj());
        if (!Cnpj.isValid(normalizedCnpj)) {
            throw new IllegalArgumentException("CNPJ inválido.");
        }

        if (companyRepository.existsByCnpjAndIdNot(normalizedCnpj, id)) {
            throw new DuplicateResourceException("DUPLICATE_CNPJ", "CNPJ já cadastrado para outra empresa.");
        }

        company.setLegalName(request.legalName());
        company.setTradeName(request.tradeName());
        company.setCnpj(normalizedCnpj);
        company.setActive(request.active());

        Company updated = companyRepository.save(company);
        return companyMapper.toResponse(updated);
    }
}
