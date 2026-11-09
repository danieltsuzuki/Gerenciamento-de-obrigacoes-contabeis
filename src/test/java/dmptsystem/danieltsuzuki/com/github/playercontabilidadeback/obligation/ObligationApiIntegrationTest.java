package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.AbstractIntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
class ObligationApiIntegrationTest extends AbstractIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String obtainBearerToken() throws Exception {
        jdbcTemplate.update("DELETE FROM users WHERE email = 'obligation_admin@empresa.com'");
        jdbcTemplate.update(
                "INSERT INTO users (name, email, password, active, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())",
                "Obligation Admin",
                "obligation_admin@empresa.com",
                passwordEncoder.encode("secretObligation123"),
                true
        );

        String loginJson = """
                {
                    "email": "obligation_admin@empresa.com",
                    "password": "secretObligation123"
                }
                """;

        String loginResponse = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginJson))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        return com.jayway.jsonpath.JsonPath.read(loginResponse, "$.token");
    }

    private Long insertCompany(String legalName, String tradeName, String cnpj, boolean active) {
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                    "INSERT INTO company (legal_name, trade_name, cnpj, active, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())",
                    Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, legalName);
            ps.setString(2, tradeName);
            ps.setString(3, cnpj);
            ps.setBoolean(4, active);
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    private Long insertUser(String name, String email, boolean active) {
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                    "INSERT INTO users (name, email, password, active, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())",
                    Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, passwordEncoder.encode("senha123"));
            ps.setBoolean(4, active);
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    @Test
    @DisplayName("Ciclo completo da API de Obrigações: autenticação JWT, validação RN-006 (ativos), máquina de estados RN-008, anexos e bloqueio 405 de DELETE")
    void testObligationApiLifecycle() throws Exception {
        String token = obtainBearerToken();
        String authHeader = "Bearer " + token;

        // Limpeza de tabelas filhas para isolamento do teste
        jdbcTemplate.update("DELETE FROM attachment");
        jdbcTemplate.update("DELETE FROM obligation");

        // Criação de fixtures
        Long activeCompanyId = insertCompany("Empresa Ativa LTDA", "Empresa Ativa", "11222333000181", true);
        Long inactiveCompanyId = insertCompany("Empresa Inativa LTDA", "Empresa Inativa", "22333444000192", false);
        Long activeUserId = insertUser("Contador Ativo", "contador.ativo@empresa.com", true);
        Long inactiveUserId = insertUser("Contador Inativo", "contador.inativo@empresa.com", false);

        String futureDueDate = LocalDate.now().plusDays(15).toString();

        // 1. POST sem token deve retornar 401 UNAUTHORIZED
        String validPayload = """
                {
                    "companyId": %d,
                    "responsibleId": %d,
                    "title": "Declaração de Débitos e Créditos Tributários Federais",
                    "description": "DCTF mensal referente ao período de apuração anterior",
                    "dueDate": "%s"
                }
                """.formatted(activeCompanyId, activeUserId, futureDueDate);

        mockMvc.perform(post("/api/obligations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validPayload))
                .andExpect(status().isUnauthorized());

        // 2. POST com empresa inexistente -> 404 NOT_FOUND
        String nonExistentCompanyPayload = """
                {
                    "companyId": 999999,
                    "responsibleId": %d,
                    "title": "DCTF",
                    "description": "Desc",
                    "dueDate": "%s"
                }
                """.formatted(activeUserId, futureDueDate);

        mockMvc.perform(post("/api/obligations")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(nonExistentCompanyPayload))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));

        // 3. POST com responsável inexistente -> 404 NOT_FOUND
        String nonExistentUserPayload = """
                {
                    "companyId": %d,
                    "responsibleId": 999999,
                    "title": "DCTF",
                    "description": "Desc",
                    "dueDate": "%s"
                }
                """.formatted(activeCompanyId, futureDueDate);

        mockMvc.perform(post("/api/obligations")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(nonExistentUserPayload))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));

        // 4. POST com empresa inativa (RN-006) -> 422 UNPROCESSABLE_ENTITY
        String inactiveCompanyPayload = """
                {
                    "companyId": %d,
                    "responsibleId": %d,
                    "title": "DCTF Inativa",
                    "description": "Tentativa com empresa inativa",
                    "dueDate": "%s"
                }
                """.formatted(inactiveCompanyId, activeUserId, futureDueDate);

        mockMvc.perform(post("/api/obligations")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(inactiveCompanyPayload))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("COMPANY_INACTIVE"));

        // 5. POST com responsável inativo (RN-006) -> 422 UNPROCESSABLE_ENTITY
        String inactiveUserPayload = """
                {
                    "companyId": %d,
                    "responsibleId": %d,
                    "title": "DCTF Responsável Inativo",
                    "description": "Tentativa com responsável inativo",
                    "dueDate": "%s"
                }
                """.formatted(activeCompanyId, inactiveUserId, futureDueDate);

        mockMvc.perform(post("/api/obligations")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(inactiveUserPayload))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("USER_INACTIVE"));

        // 6. POST com sucesso -> 201 CREATED (status padrão PENDING, attachmentCount = 0)
        String createResponse = mockMvc.perform(post("/api/obligations")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(validPayload))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNumber())
                .andExpect(jsonPath("$.title").value("Declaração de Débitos e Créditos Tributários Federais"))
                .andExpect(jsonPath("$.status").value("PENDING"))
                .andExpect(jsonPath("$.dueDate").value(futureDueDate))
                .andExpect(jsonPath("$.createdAt").isNotEmpty())
                .andExpect(jsonPath("$.completedAt").isEmpty())
                .andExpect(jsonPath("$.company.id").value(activeCompanyId))
                .andExpect(jsonPath("$.company.legalName").value("Empresa Ativa LTDA"))
                .andExpect(jsonPath("$.company.cnpj").value("11222333000181"))
                .andExpect(jsonPath("$.responsible.id").value(activeUserId))
                .andExpect(jsonPath("$.responsible.name").value("Contador Ativo"))
                .andExpect(jsonPath("$.responsible.email").value("contador.ativo@empresa.com"))
                .andExpect(jsonPath("$.attachmentCount").value(0))
                .andReturn().getResponse().getContentAsString();

        Number createdIdNum = com.jayway.jsonpath.JsonPath.read(createResponse, "$.id");
        Long obligationId = createdIdNum.longValue();

        // 7. GET /api/obligations/{id} anônimo deve ser permitido -> 200 OK
        mockMvc.perform(get("/api/obligations/{id}", obligationId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(obligationId))
                .andExpect(jsonPath("$.status").value("PENDING"))
                .andExpect(jsonPath("$.company.id").value(activeCompanyId))
                .andExpect(jsonPath("$.attachmentCount").value(0));

        // 8. Inserir anexo diretamente no banco para testar contagem de anexos na listagem
        jdbcTemplate.update(
                "INSERT INTO attachment (obligation_id, file_name, file_path, content_type, file_size, uploaded_at) VALUES (?, ?, ?, ?, ?, NOW())",
                obligationId,
                "comprovante_dctf.pdf",
                "/uploads/comprovante_dctf.pdf",
                "application/pdf",
                1024L
        );

        // 9. GET /api/obligations com paginação e filtros anônimo -> 200 OK
        mockMvc.perform(get("/api/obligations")
                        .param("companyId", activeCompanyId.toString())
                        .param("status", "PENDING")
                        .param("page", "0")
                        .param("size", "10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content", hasSize(1)))
                .andExpect(jsonPath("$.content[0].id").value(obligationId))
                .andExpect(jsonPath("$.content[0].company.legalName").value("Empresa Ativa LTDA"))
                .andExpect(jsonPath("$.content[0].responsible.name").value("Contador Ativo"))
                .andExpect(jsonPath("$.content[0].status").value("PENDING"))
                .andExpect(jsonPath("$.content[0].attachmentCount").value(1));

        // 10. PATCH /api/obligations/{id}/status sem autenticação -> 401 UNAUTHORIZED
        mockMvc.perform(patch("/api/obligations/{id}/status", obligationId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"IN_PROGRESS\"}"))
                .andExpect(status().isUnauthorized());

        // 11. PATCH com salto PENDING -> COMPLETED rejeitado pelo domínio (RN-008) -> 422 INVALID_STATUS_TRANSITION
        mockMvc.perform(patch("/api/obligations/{id}/status", obligationId)
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"COMPLETED\"}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("INVALID_STATUS_TRANSITION"));

        // 12. PATCH com transição válida PENDING -> IN_PROGRESS -> 200 OK (completedAt deve continuar null)
        mockMvc.perform(patch("/api/obligations/{id}/status", obligationId)
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"IN_PROGRESS\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(obligationId))
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"))
                .andExpect(jsonPath("$.completedAt").isEmpty())
                .andExpect(jsonPath("$.attachmentCount").value(1));

        // 13. PATCH com regressão IN_PROGRESS -> PENDING rejeitada (RN-008) -> 422 INVALID_STATUS_TRANSITION
        mockMvc.perform(patch("/api/obligations/{id}/status", obligationId)
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"PENDING\"}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("INVALID_STATUS_TRANSITION"));

        // 14. PATCH para o mesmo status IN_PROGRESS -> IN_PROGRESS rejeitado -> 422 INVALID_STATUS_TRANSITION
        mockMvc.perform(patch("/api/obligations/{id}/status", obligationId)
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"IN_PROGRESS\"}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("INVALID_STATUS_TRANSITION"));

        // 15. PATCH com transição válida IN_PROGRESS -> COMPLETED -> 200 OK (completedAt preenchido)
        mockMvc.perform(patch("/api/obligations/{id}/status", obligationId)
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"COMPLETED\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(obligationId))
                .andExpect(jsonPath("$.status").value("COMPLETED"))
                .andExpect(jsonPath("$.completedAt").isNotEmpty());

        // 16. PATCH a partir de COMPLETED (terminal) tentando reabrir para IN_PROGRESS ou PENDING -> 422
        mockMvc.perform(patch("/api/obligations/{id}/status", obligationId)
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"IN_PROGRESS\"}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("INVALID_STATUS_TRANSITION"));

        mockMvc.perform(patch("/api/obligations/{id}/status", obligationId)
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\": \"PENDING\"}"))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("INVALID_STATUS_TRANSITION"));

        // 17. PUT de atualização cadastral (sem alterar status)
        String updatePayload = """
                {
                    "companyId": %d,
                    "responsibleId": %d,
                    "title": "DCTF Retificadora Finalizada",
                    "description": "Atualizada com sucesso",
                    "dueDate": "%s",
                    "status": "COMPLETED"
                }
                """.formatted(activeCompanyId, activeUserId, futureDueDate);

        mockMvc.perform(put("/api/obligations/{id}", obligationId)
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updatePayload))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("DCTF Retificadora Finalizada"))
                .andExpect(jsonPath("$.status").value("COMPLETED"));

        // 18. DELETE /api/obligations/{id} sem autenticação -> 401 UNAUTHORIZED; com autenticação -> 405 METHOD_NOT_ALLOWED
        mockMvc.perform(delete("/api/obligations/{id}", obligationId))
                .andExpect(status().isUnauthorized());

        mockMvc.perform(delete("/api/obligations/{id}", obligationId)
                        .header("Authorization", authHeader))
                .andExpect(status().isMethodNotAllowed());

        // 19. Garantir que o registro NUNCA é removido fisicamente e que status/completed_at foram persistidos
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM obligation WHERE id = ?",
                Integer.class,
                obligationId
        );
        assertThat(count).isEqualTo(1);

        String persistedStatus = jdbcTemplate.queryForObject(
                "SELECT status FROM obligation WHERE id = ?",
                String.class,
                obligationId
        );
        assertThat(persistedStatus).isEqualTo("COMPLETED");

        java.sql.Timestamp persistedCompletedAt = jdbcTemplate.queryForObject(
                "SELECT completed_at FROM obligation WHERE id = ?",
                java.sql.Timestamp.class,
                obligationId
        );
        assertThat(persistedCompletedAt).isNotNull();
    }
}
