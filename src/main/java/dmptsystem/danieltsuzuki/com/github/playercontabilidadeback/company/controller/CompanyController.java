package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanyResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CreateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.UpdateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.service.CompanyService;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/companies")
public class CompanyController {

    private final CompanyService companyService;

    public CompanyController(CompanyService companyService) {
        this.companyService = companyService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CompanyResponse create(@Valid @RequestBody CreateCompanyRequest request) {
        return companyService.create(request);
    }

    @GetMapping
    public Page<CompanyResponse> list(
            @RequestParam(required = false) Boolean active,
            Pageable pageable
    ) {
        return companyService.findAll(active, pageable);
    }

    @GetMapping("/{id}")
    public CompanyResponse getById(@PathVariable Long id) {
        return companyService.findById(id);
    }

    @PutMapping("/{id}")
    public CompanyResponse update(
            @PathVariable Long id,
            @Valid @RequestBody UpdateCompanyRequest request
    ) {
        return companyService.update(id, request);
    }
}
