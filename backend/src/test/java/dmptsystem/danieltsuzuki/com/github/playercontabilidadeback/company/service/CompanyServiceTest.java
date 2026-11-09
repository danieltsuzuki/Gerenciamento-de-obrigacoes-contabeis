package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanyResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CreateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.UpdateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.mapper.CompanyMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.repository.CompanyRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.DuplicateResourceException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class CompanyServiceTest {

    private static final String VALID_FORMATTED_CNPJ = "33.000.167/0001-01";
    private static final String VALID_NORMALIZED_CNPJ = "33000167000101";

    @Mock
    private CompanyRepository companyRepository;

    private CompanyMapper companyMapper;
    private CompanyService companyService;

    @BeforeEach
    void setUp() {
        companyMapper = new CompanyMapper();
        companyService = new CompanyService(companyRepository, companyMapper);
    }

    @Test
    @DisplayName("deve criar empresa com sucesso com CNPJ normalizado")
    void shouldCreateCompanySuccessfully() {
        CreateCompanyRequest request = new CreateCompanyRequest(
                "Petrobras SA",
                "Petrobras",
                VALID_FORMATTED_CNPJ,
                true
        );

        when(companyRepository.existsByCnpj(VALID_NORMALIZED_CNPJ)).thenReturn(false);
        when(companyRepository.save(any(Company.class))).thenAnswer(invocation -> {
            Company c = invocation.getArgument(0);
            return c;
        });

        CompanyResponse response = companyService.create(request);

        assertThat(response.legalName()).isEqualTo("Petrobras SA");
        assertThat(response.tradeName()).isEqualTo("Petrobras");
        assertThat(response.cnpj()).isEqualTo(VALID_NORMALIZED_CNPJ);
        assertThat(response.active()).isTrue();

        verify(companyRepository).save(any(Company.class));
    }

    @Test
    @DisplayName("deve lançar exceção ao tentar criar empresa com CNPJ duplicado")
    void shouldThrowWhenCreatingWithDuplicateCnpj() {
        CreateCompanyRequest request = new CreateCompanyRequest(
                "Outra Empresa",
                "Outra",
                VALID_FORMATTED_CNPJ,
                true
        );

        when(companyRepository.existsByCnpj(VALID_NORMALIZED_CNPJ)).thenReturn(true);

        assertThatThrownBy(() -> companyService.create(request))
                .isInstanceOf(DuplicateResourceException.class)
                .hasMessageContaining("CNPJ já cadastrado");

        verify(companyRepository, never()).save(any());
    }

    @Test
    @DisplayName("deve lançar exceção ao tentar criar empresa com CNPJ inválido")
    void shouldThrowWhenCreatingWithInvalidCnpj() {
        CreateCompanyRequest request = new CreateCompanyRequest(
                "Empresa Inválida",
                "Inválida",
                "12345678000199",
                true
        );

        assertThatThrownBy(() -> companyService.create(request))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("CNPJ inválido");

        verify(companyRepository, never()).save(any());
    }

    @Test
    @DisplayName("deve buscar empresa por ID existente com sucesso")
    void shouldFindCompanyById() {
        Company company = new Company();
        company.setLegalName("Empresa Exemplo");
        company.setCnpj(VALID_NORMALIZED_CNPJ);
        company.setActive(true);

        when(companyRepository.findById(1L)).thenReturn(Optional.of(company));

        CompanyResponse response = companyService.findById(1L);

        assertThat(response.legalName()).isEqualTo("Empresa Exemplo");
        assertThat(response.cnpj()).isEqualTo(VALID_NORMALIZED_CNPJ);
    }

    @Test
    @DisplayName("deve lançar NotFoundException quando empresa não for encontrada por ID")
    void shouldThrowNotFoundWhenCompanyDoesNotExist() {
        when(companyRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> companyService.findById(99L))
                .isInstanceOf(NotFoundException.class)
                .hasMessageContaining("Empresa");
    }

    @Test
    @DisplayName("deve listar empresas com paginação e sem filtro de active")
    void shouldListAllCompaniesWithoutFilter() {
        Company company = new Company();
        company.setLegalName("Empresa 1");
        company.setCnpj(VALID_NORMALIZED_CNPJ);

        Pageable pageable = PageRequest.of(0, 10);
        when(companyRepository.findAll(pageable))
                .thenReturn(new PageImpl<>(List.of(company), pageable, 1));

        Page<CompanyResponse> result = companyService.findAll(null, pageable);

        assertThat(result.getTotalElements()).isEqualTo(1);
        assertThat(result.getContent().get(0).legalName()).isEqualTo("Empresa 1");
        verify(companyRepository).findAll(pageable);
        verify(companyRepository, never()).findByActive(any(Boolean.class), any());
    }

    @Test
    @DisplayName("deve listar empresas filtrando por active")
    void shouldListCompaniesFilteredByActive() {
        Company company = new Company();
        company.setLegalName("Empresa Ativa");
        company.setCnpj(VALID_NORMALIZED_CNPJ);
        company.setActive(true);

        Pageable pageable = PageRequest.of(0, 10);
        when(companyRepository.findByActive(true, pageable))
                .thenReturn(new PageImpl<>(List.of(company), pageable, 1));

        Page<CompanyResponse> result = companyService.findAll(true, pageable);

        assertThat(result.getTotalElements()).isEqualTo(1);
        assertThat(result.getContent().get(0).legalName()).isEqualTo("Empresa Ativa");
        verify(companyRepository).findByActive(true, pageable);
        verify(companyRepository, never()).findAll(any(Pageable.class));
    }

    @Test
    @DisplayName("deve atualizar empresa com sucesso inclusive alterando situação (active)")
    void shouldUpdateCompanySuccessfully() {
        Company existing = new Company();
        existing.setLegalName("Nome Antigo");
        existing.setCnpj(VALID_NORMALIZED_CNPJ);
        existing.setActive(true);

        UpdateCompanyRequest updateRequest = new UpdateCompanyRequest(
                "Nome Atualizado",
                "Novo Fantasia",
                VALID_NORMALIZED_CNPJ,
                false
        );

        when(companyRepository.findById(1L)).thenReturn(Optional.of(existing));
        when(companyRepository.existsByCnpjAndIdNot(VALID_NORMALIZED_CNPJ, 1L)).thenReturn(false);
        when(companyRepository.save(existing)).thenReturn(existing);

        CompanyResponse response = companyService.update(1L, updateRequest);

        assertThat(response.legalName()).isEqualTo("Nome Atualizado");
        assertThat(response.tradeName()).isEqualTo("Novo Fantasia");
        assertThat(response.active()).isFalse();

        verify(companyRepository).save(existing);
    }

    @Test
    @DisplayName("deve lançar exceção ao atualizar para CNPJ já pertencente a outra empresa")
    void shouldThrowWhenUpdatingToExistingCnpjOfAnotherCompany() {
        Company existing = new Company();
        existing.setLegalName("Minha Empresa");
        existing.setCnpj("00000000000191");

        UpdateCompanyRequest updateRequest = new UpdateCompanyRequest(
                "Minha Empresa",
                null,
                VALID_FORMATTED_CNPJ,
                true
        );

        when(companyRepository.findById(1L)).thenReturn(Optional.of(existing));
        when(companyRepository.existsByCnpjAndIdNot(VALID_NORMALIZED_CNPJ, 1L)).thenReturn(true);

        assertThatThrownBy(() -> companyService.update(1L, updateRequest))
                .isInstanceOf(DuplicateResourceException.class)
                .hasMessageContaining("CNPJ já cadastrado");

        verify(companyRepository, never()).save(any());
    }
}

