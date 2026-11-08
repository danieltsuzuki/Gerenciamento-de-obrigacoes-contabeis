package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.AbstractIntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.web.servlet.MockMvc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
class CompanyApiIntegrationTest extends AbstractIntegrationTest {

    private static final String PETROBRAS_CNPJ_FORMATTED = "33.000.167/0001-01";
    private static final String PETROBRAS_CNPJ_NORMALIZED = "33000167000101";

    private static final String AMBEV_CNPJ_FORMATTED = "07.526.557/0001-00";
    private static final String AMBEV_CNPJ_NORMALIZED = "07526557000100";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    @DisplayName("Ciclo completo da API de Company: criação, busca, listagem, atualização/inativação e bloqueio de exclusão física")
    void testCompanyApiLifecycle() throws Exception {
        // 1. POST /api/companies -> Criação com sucesso
        String createJson = """
                {
                    "legalName": "Petróleo Brasileiro S.A.",
                    "tradeName": "Petrobras",
                    "cnpj": "%s",
                    "active": true
                }
                """.formatted(PETROBRAS_CNPJ_FORMATTED);

        String createResponse = mockMvc.perform(post("/api/companies")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNumber())
                .andExpect(jsonPath("$.legalName").value("Petróleo Brasileiro S.A."))
                .andExpect(jsonPath("$.tradeName").value("Petrobras"))
                .andExpect(jsonPath("$.cnpj").value(PETROBRAS_CNPJ_NORMALIZED))
                .andExpect(jsonPath("$.active").value(true))
                .andReturn().getResponse().getContentAsString();

        // Extrai o ID gerado da resposta
        Number idNumber = com.jayway.jsonpath.JsonPath.read(createResponse, "$.id");
        Long companyId = idNumber.longValue();

        // Valida no banco de dados que foi persistido normalizado
        String dbCnpj = jdbcTemplate.queryForObject(
                "SELECT cnpj FROM company WHERE id = ?",
                String.class,
                companyId
        );
        assertThat(dbCnpj).isEqualTo(PETROBRAS_CNPJ_NORMALIZED);

        // 2. POST /api/companies com CNPJ duplicado -> 409 Conflict
        mockMvc.perform(post("/api/companies")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createJson))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DUPLICATE_CNPJ"));

        // 3. POST /api/companies com CNPJ inválido -> 400 Bad Request
        String invalidCnpjJson = """
                {
                    "legalName": "Empresa Errada",
                    "cnpj": "12345678000199"
                }
                """;
        mockMvc.perform(post("/api/companies")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(invalidCnpjJson))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));

        // 4. GET /api/companies/{id} -> 200 OK
        mockMvc.perform(get("/api/companies/" + companyId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(companyId))
                .andExpect(jsonPath("$.legalName").value("Petróleo Brasileiro S.A."));

        // 5. GET /api/companies/{id} inexistente -> 404 Not Found
        mockMvc.perform(get("/api/companies/999999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));

        // 6. Criar uma segunda empresa para testar listagem
        String createSecondJson = """
                {
                    "legalName": "Ambev S.A.",
                    "tradeName": "Ambev",
                    "cnpj": "%s",
                    "active": true
                }
                """.formatted(AMBEV_CNPJ_FORMATTED);
        mockMvc.perform(post("/api/companies")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createSecondJson))
                .andExpect(status().isCreated());

        // 7. GET /api/companies -> Listagem paginada
        mockMvc.perform(get("/api/companies?page=0&size=10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.page.totalElements").value(org.hamcrest.Matchers.greaterThanOrEqualTo(2)));

        // 8. PUT /api/companies/{id} -> Atualização e inativação (soft delete)
        String updateJson = """
                {
                    "legalName": "Petróleo Brasileiro S.A. - Em Liquidação",
                    "tradeName": "Petrobras Antiga",
                    "cnpj": "%s",
                    "active": false
                }
                """.formatted(PETROBRAS_CNPJ_FORMATTED);

        mockMvc.perform(put("/api/companies/" + companyId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updateJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.legalName").value("Petróleo Brasileiro S.A. - Em Liquidação"))
                .andExpect(jsonPath("$.tradeName").value("Petrobras Antiga"))
                .andExpect(jsonPath("$.active").value(false));

        // Valida no banco que active agora é false
        Boolean dbActive = jdbcTemplate.queryForObject(
                "SELECT active FROM company WHERE id = ?",
                Boolean.class,
                companyId
        );
        assertThat(dbActive).isFalse();

        // 9. GET /api/companies?active=false -> Deve trazer a empresa inativada
        mockMvc.perform(get("/api/companies?active=false&page=0&size=10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[?(@.id == " + companyId + ")].active").value(false));

        // 10. DELETE /api/companies/{id} -> 405 Method Not Allowed (Sem exclusão física)
        mockMvc.perform(delete("/api/companies/" + companyId))
                .andExpect(status().isMethodNotAllowed());
    }
}
