package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.AbstractIntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
class AttachmentApiIntegrationTest extends AbstractIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String obtainBearerToken() throws Exception {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM users WHERE email = 'attachment_admin@empresa.com'", Integer.class);
        if (count == null || count == 0) {
            jdbcTemplate.update(
                    "INSERT INTO users (name, email, password, active, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())",
                    "Attachment Admin",
                    "attachment_admin@empresa.com",
                    passwordEncoder.encode("secretAttachment123"),
                    true
            );
        } else {
            jdbcTemplate.update(
                    "UPDATE users SET password = ?, active = true WHERE email = 'attachment_admin@empresa.com'",
                    passwordEncoder.encode("secretAttachment123")
            );
        }

        String loginJson = """
                {
                    "email": "attachment_admin@empresa.com",
                    "password": "secretAttachment123"
                }
                """;

        String loginResponse = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginJson))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        return com.jayway.jsonpath.JsonPath.read(loginResponse, "$.token");
    }

    private Long insertCompany(String legalName, String cnpj) {
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                    "INSERT INTO company (legal_name, cnpj, active, created_at, updated_at) VALUES (?, ?, true, NOW(), NOW())",
                    Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, legalName);
            ps.setString(2, cnpj);
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    private Long insertUser(String name, String email) {
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                    "INSERT INTO users (name, email, password, active, created_at, updated_at) VALUES (?, ?, ?, true, NOW(), NOW())",
                    Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, passwordEncoder.encode("senha123"));
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    private Long insertObligation(Long companyId, Long responsibleId, String title) {
        KeyHolder keyHolder = new GeneratedKeyHolder();
        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                    "INSERT INTO obligation (company_id, responsible_id, title, due_date, status, created_at, updated_at) VALUES (?, ?, ?, ?, 'PENDING', NOW(), NOW())",
                    Statement.RETURN_GENERATED_KEYS
            );
            ps.setLong(1, companyId);
            ps.setLong(2, responsibleId);
            ps.setString(3, title);
            ps.setDate(4, java.sql.Date.valueOf(LocalDate.now().plusDays(10)));
            return ps;
        }, keyHolder);
        return keyHolder.getKey().longValue();
    }

    @Test
    @DisplayName("Ciclo completo da API de Anexos: autenticação JWT obrigatória para upload/listagem/download, validações e persistência física")
    void testAttachmentApiLifecycle() throws Exception {
        String token = obtainBearerToken();
        String authHeader = "Bearer " + token;

        jdbcTemplate.update("DELETE FROM attachment");
        jdbcTemplate.update("DELETE FROM obligation_status_history");
        jdbcTemplate.update("DELETE FROM obligation");

        Long companyId = insertCompany("Empresa Anexos LTDA", "55666777000188");
        Long userId = insertUser("Contador Anexos", "contador.anexos@empresa.com");
        Long obligationId = insertObligation(companyId, userId, "Obrigação com Anexo");

        byte[] pdfBytes = "%PDF-1.4 Simulação de comprovante de arrecadação DARF".getBytes();
        MockMultipartFile validFile = new MockMultipartFile(
                "file",
                "comprovante_darf.pdf",
                "application/pdf",
                pdfBytes
        );

        // 1. Upload anônimo sem token -> 401 UNAUTHORIZED
        mockMvc.perform(multipart("/api/obligations/{id}/attachments", obligationId)
                        .file(validFile))
                .andExpect(status().isUnauthorized());

        // 2. Listagem anônima sem token -> 401 UNAUTHORIZED
        mockMvc.perform(get("/api/obligations/{id}/attachments", obligationId))
                .andExpect(status().isUnauthorized());

        // 3. Download anônimo sem token -> 401 UNAUTHORIZED
        mockMvc.perform(get("/api/attachments/1/download"))
                .andExpect(status().isUnauthorized());

        // 4. Upload autenticado com arquivo vazio -> 400 VALIDATION_ERROR
        MockMultipartFile emptyFile = new MockMultipartFile(
                "file", "vazio.pdf", "application/pdf", new byte[0]
        );
        mockMvc.perform(multipart("/api/obligations/{id}/attachments", obligationId)
                        .file(emptyFile)
                        .header("Authorization", authHeader))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));

        // 5. Upload autenticado com tipo MIME não suportado -> 400 VALIDATION_ERROR
        MockMultipartFile exeFile = new MockMultipartFile(
                "file", "executavel.exe", "application/x-msdownload", "malware fake".getBytes()
        );
        mockMvc.perform(multipart("/api/obligations/{id}/attachments", obligationId)
                        .file(exeFile)
                        .header("Authorization", authHeader))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));

        // 6. Upload autenticado em obrigação inexistente -> 404 NOT_FOUND
        mockMvc.perform(multipart("/api/obligations/999999/attachments")
                        .file(validFile)
                        .header("Authorization", authHeader))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));

        // 7. Upload autenticado com sucesso -> 201 CREATED
        String uploadResponse = mockMvc.perform(multipart("/api/obligations/{id}/attachments", obligationId)
                        .file(validFile)
                        .header("Authorization", authHeader))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNumber())
                .andExpect(jsonPath("$.name").value("comprovante_darf.pdf"))
                .andExpect(jsonPath("$.contentType").value("application/pdf"))
                .andExpect(jsonPath("$.size").value(pdfBytes.length))
                .andExpect(jsonPath("$.uploadedAt").isNotEmpty())
                .andReturn().getResponse().getContentAsString();

        Number attachmentIdNum = com.jayway.jsonpath.JsonPath.read(uploadResponse, "$.id");
        Long attachmentId = attachmentIdNum.longValue();

        // 8. Listagem autenticada dos anexos da obrigação -> 200 OK
        mockMvc.perform(get("/api/obligations/{id}/attachments", obligationId)
                        .header("Authorization", authHeader))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].id").value(attachmentId))
                .andExpect(jsonPath("$[0].name").value("comprovante_darf.pdf"))
                .andExpect(jsonPath("$[0].size").value(pdfBytes.length));

        // 9. Download autenticado do anexo -> 200 OK com cabeçalhos corretos e bytes idênticos
        mockMvc.perform(get("/api/attachments/{attachmentId}/download", attachmentId)
                        .header("Authorization", authHeader))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.CONTENT_TYPE, "application/pdf"))
                .andExpect(header().string(HttpHeaders.CONTENT_DISPOSITION, containsString("attachment; filename=\"comprovante_darf.pdf\"")))
                .andExpect(content().bytes(pdfBytes));

        // 10. Bloqueio de DELETE físico -> 405 Method Not Allowed
        mockMvc.perform(delete("/api/obligations/{id}/attachments", obligationId)
                        .header("Authorization", authHeader))
                .andExpect(status().isMethodNotAllowed());

        mockMvc.perform(delete("/api/attachments/{id}/download", attachmentId)
                        .header("Authorization", authHeader))
                .andExpect(status().isMethodNotAllowed());

        // 11. Validação no MySQL: registro do anexo deve existir com metadados íntegros
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM attachment WHERE id = ? AND obligation_id = ?",
                Integer.class,
                attachmentId,
                obligationId
        );
        assertThat(count).isEqualTo(1);

        String storedName = jdbcTemplate.queryForObject(
                "SELECT file_name FROM attachment WHERE id = ?",
                String.class,
                attachmentId
        );
        assertThat(storedName).isEqualTo("comprovante_darf.pdf");

        String storedPath = jdbcTemplate.queryForObject(
                "SELECT file_path FROM attachment WHERE id = ?",
                String.class,
                attachmentId
        );
        assertThat(storedPath).startsWith(obligationId + "/").endsWith(".pdf");
    }
}

