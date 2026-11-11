package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanyResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CreateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.UpdateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.service.CompanyService;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.DuplicateResourceException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.GlobalExceptionHandler;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(CompanyController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class CompanyControllerTest {

    private static final String VALID_CNPJ = "33.000.167/0001-01";
    private static final String NORMALIZED_CNPJ = "33000167000101";

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private CompanyService companyService;

    @Test
    @DisplayName("POST /api/companies deve retornar 201 Created quando payload for válido")
    void shouldReturn201WhenCreatingCompany() throws Exception {
        CompanyResponse response = new CompanyResponse(
                1L,
                "Petrobras SA",
                "Petrobras",
                NORMALIZED_CNPJ,
                true,
                LocalDateTime.now(),
                LocalDateTime.now()
        );

        when(companyService.create(any(CreateCompanyRequest.class))).thenReturn(response);

        String json = """
                {
                    "legalName": "Petrobras SA",
                    "tradeName": "Petrobras",
                    "cnpj": "33.000.167/0001-01",
                    "active": true
                }
                """;

        mockMvc.perform(post("/api/companies")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.legalName").value("Petrobras SA"))
                .andExpect(jsonPath("$.tradeName").value("Petrobras"))
                .andExpect(jsonPath("$.cnpj").value(NORMALIZED_CNPJ))
                .andExpect(jsonPath("$.active").value(true));
    }

    @Test
    @DisplayName("POST /api/companies deve retornar 400 Bad Request quando CNPJ for inválido")
    void shouldReturn400WhenCnpjIsInvalid() throws Exception {
        String json = """
                {
                    "legalName": "Empresa Inválida",
                    "cnpj": "12345678000199"
                }
                """;

        mockMvc.perform(post("/api/companies")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.details").isArray());
    }

    @Test
    @DisplayName("POST /api/companies deve retornar 400 Bad Request quando razão social for vazia")
    void shouldReturn400WhenLegalNameIsBlank() throws Exception {
        String json = """
                {
                    "legalName": "",
                    "cnpj": "33.000.167/0001-01"
                }
                """;

        mockMvc.perform(post("/api/companies")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    @DisplayName("POST /api/companies deve retornar 409 Conflict quando CNPJ for duplicado")
    void shouldReturn409WhenCnpjIsDuplicate() throws Exception {
        when(companyService.create(any(CreateCompanyRequest.class)))
                .thenThrow(new DuplicateResourceException("DUPLICATE_CNPJ", "CNPJ já cadastrado para outra empresa."));

        String json = """
                {
                    "legalName": "Empresa Duplicada",
                    "cnpj": "33.000.167/0001-01"
                }
                """;

        mockMvc.perform(post("/api/companies")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DUPLICATE_CNPJ"))
                .andExpect(jsonPath("$.message").value("CNPJ já cadastrado para outra empresa."));
    }

    @Test
    @DisplayName("GET /api/companies/{id} deve retornar 200 OK quando empresa existir")
    void shouldReturn200WhenGettingCompanyById() throws Exception {
        CompanyResponse response = new CompanyResponse(
                1L,
                "Empresa Existente",
                null,
                NORMALIZED_CNPJ,
                true,
                LocalDateTime.now(),
                LocalDateTime.now()
        );

        when(companyService.findById(1L)).thenReturn(response);

        mockMvc.perform(get("/api/companies/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.legalName").value("Empresa Existente"));
    }

    @Test
    @DisplayName("GET /api/companies/{id} deve retornar 404 Not Found quando empresa não existir")
    void shouldReturn404WhenCompanyDoesNotExist() throws Exception {
        when(companyService.findById(999L))
                .thenThrow(new NotFoundException("Empresa", 999L));

        mockMvc.perform(get("/api/companies/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"))
                .andExpect(jsonPath("$.message").value("Empresa não encontrada(o) com identificador: 999"));
    }

    @Test
    @DisplayName("GET /api/companies deve retornar 200 OK com página de resultados")
    void shouldReturn200WhenListingCompanies() throws Exception {
        CompanyResponse response = new CompanyResponse(
                1L,
                "Empresa Ativa",
                null,
                NORMALIZED_CNPJ,
                true,
                LocalDateTime.now(),
                LocalDateTime.now()
        );

        PageRequest pageRequest = PageRequest.of(0, 10);
        when(companyService.findAll(eq(true), any()))
                .thenReturn(new PageImpl<>(List.of(response), pageRequest, 1));

        mockMvc.perform(get("/api/companies?active=true&page=0&size=10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].id").value(1))
                .andExpect(jsonPath("$.totalElements").value(1));
    }

    @Test
    @DisplayName("PUT /api/companies/{id} deve retornar 200 OK ao atualizar empresa")
    void shouldReturn200WhenUpdatingCompany() throws Exception {
        CompanyResponse response = new CompanyResponse(
                1L,
                "Nome Alterado",
                "Novo Fantasia",
                NORMALIZED_CNPJ,
                false,
                LocalDateTime.now(),
                LocalDateTime.now()
        );

        when(companyService.update(eq(1L), any(UpdateCompanyRequest.class))).thenReturn(response);

        String json = """
                {
                    "legalName": "Nome Alterado",
                    "tradeName": "Novo Fantasia",
                    "cnpj": "33.000.167/0001-01",
                    "active": false
                }
                """;

        mockMvc.perform(put("/api/companies/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(json))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.legalName").value("Nome Alterado"))
                .andExpect(jsonPath("$.tradeName").value("Novo Fantasia"))
                .andExpect(jsonPath("$.active").value(false));
    }

    @Test
    @DisplayName("GET /api/companies com termo de busca q deve retornar 200 OK")
    void shouldReturn200WhenSearchingCompanies() throws Exception {
        CompanyResponse response = new CompanyResponse(
                1L,
                "Petróleo Brasileiro S.A.",
                "Petrobras",
                NORMALIZED_CNPJ,
                true,
                LocalDateTime.now(),
                LocalDateTime.now()
        );

        when(companyService.findAll(eq(true), eq("petro"), any(PageRequest.class)))
                .thenReturn(new PageImpl<>(List.of(response)));

        mockMvc.perform(get("/api/companies?active=true&q=petro&page=0&size=10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].tradeName").value("Petrobras"));
    }

    @Test
    @DisplayName("GET /api/companies com q excedendo 100 caracteres deve retornar 400 VALIDATION_ERROR")
    void shouldReturn400WhenSearchQueryTooLong() throws Exception {
        when(companyService.findAll(any(), eq("a".repeat(101)), any()))
                .thenThrow(new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.SearchQueryTooLongException(
                        "O parâmetro de busca 'q' não pode exceder 100 caracteres."
                ));

        mockMvc.perform(get("/api/companies?q=" + "a".repeat(101)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    @DisplayName("DELETE /api/companies/{id} deve retornar 405 Method Not Allowed (sem exclusão física)")
    void shouldReturn405WhenAttemptingToDeleteCompany() throws Exception {
        mockMvc.perform(delete("/api/companies/1"))
                .andExpect(status().isMethodNotAllowed());
    }
}
