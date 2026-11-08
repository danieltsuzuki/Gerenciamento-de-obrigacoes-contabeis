package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.AbstractIntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
class ResponsibleApiIntegrationTest extends AbstractIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private String obtainBearerToken() throws Exception {
        jdbcTemplate.update("DELETE FROM users WHERE email = 'seed_admin@empresa.com'");
        jdbcTemplate.update(
                "INSERT INTO users (name, email, password, active, created_at, updated_at) VALUES (?, ?, ?, ?, NOW(), NOW())",
                "Seed Admin",
                "seed_admin@empresa.com",
                passwordEncoder.encode("senha12345"),
                true
        );

        String loginJson = """
                {
                    "email": "seed_admin@empresa.com",
                    "password": "senha12345"
                }
                """;

        String loginResponse = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(loginJson))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        return com.jayway.jsonpath.JsonPath.read(loginResponse, "$.token");
    }

    @Test
    @DisplayName("Ciclo completo da API Responsible: registro anônimo (/api/auth/register), login JWT, proteção de rotas, CRUD e soft delete")
    void testResponsibleApiLifecycle() throws Exception {
        // 0. Autocadastro de usuário sem autenticação via POST /api/auth/register
        String registerJson = """
                {
                    "name": "João Registrado",
                    "email": "joao.registrado@empresa.com",
                    "password": "senhaSegura123",
                    "active": true
                }
                """;

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(registerJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNumber())
                .andExpect(jsonPath("$.name").value("João Registrado"))
                .andExpect(jsonPath("$.email").value("joao.registrado@empresa.com"))
                .andExpect(jsonPath("$.password").doesNotExist());

        // Login imediato do usuário que acabou de se registrar
        String joaoLoginJson = """
                {
                    "email": "joao.registrado@empresa.com",
                    "password": "senhaSegura123"
                }
                """;
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(joaoLoginJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isString())
                .andExpect(jsonPath("$.expiresIn").value(1800))
                .andExpect(jsonPath("$.user.email").value("joao.registrado@empresa.com"));

        // 1. Tentar criar via POST /api/responsibles sem autenticação -> 401 UNAUTHORIZED
        String createJson = """
                {
                    "name": "Maria Contadora",
                    "email": "maria@empresa.com",
                    "password": "senhaForte123",
                    "active": true
                }
                """;

        mockMvc.perform(post("/api/responsibles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createJson))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));

        // Obter token JWT
        String token = obtainBearerToken();
        String authHeader = "Bearer " + token;

        // 2. Criar com autenticação -> 201 CREATED
        String createResponse = mockMvc.perform(post("/api/responsibles")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createJson))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").isNumber())
                .andExpect(jsonPath("$.name").value("Maria Contadora"))
                .andExpect(jsonPath("$.email").value("maria@empresa.com"))
                .andExpect(jsonPath("$.active").value(true))
                .andExpect(jsonPath("$.password").doesNotExist())
                .andReturn().getResponse().getContentAsString();

        Number idNumber = com.jayway.jsonpath.JsonPath.read(createResponse, "$.id");
        Long mariaId = idNumber.longValue();

        // Checa que o password foi gravado como hash bcrypt no banco
        String dbPassword = jdbcTemplate.queryForObject(
                "SELECT password FROM users WHERE id = ?",
                String.class,
                mariaId
        );
        assertThat(dbPassword).isNotEqualTo("senhaForte123");
        assertThat(passwordEncoder.matches("senhaForte123", dbPassword)).isTrue();

        // 3. Tentar criar com mesmo e-mail -> 409 DUPLICATE_EMAIL
        mockMvc.perform(post("/api/responsibles")
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(createJson))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DUPLICATE_EMAIL"));

        // 4. Login da nova usuária criada (Maria Contadora) -> 200 OK com expiração em 30 min (1800s)
        String mariaLoginJson = """
                {
                    "email": "maria@empresa.com",
                    "password": "senhaForte123"
                }
                """;
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(mariaLoginJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").isString())
                .andExpect(jsonPath("$.expiresIn").value(1800))
                .andExpect(jsonPath("$.user.email").value("maria@empresa.com"));

        // 5. GET /api/responsibles/{id} sem autenticação -> 200 OK (acesso anônimo permitido)
        mockMvc.perform(get("/api/responsibles/" + mariaId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(mariaId))
                .andExpect(jsonPath("$.name").value("Maria Contadora"))
                .andExpect(jsonPath("$.password").doesNotExist());

        // 6. GET /api/responsibles sem autenticação -> 200 OK
        mockMvc.perform(get("/api/responsibles?page=0&size=10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content").isArray())
                .andExpect(jsonPath("$.page.totalElements").value(org.hamcrest.Matchers.greaterThanOrEqualTo(2)));

        // 7. PUT /api/responsibles/{id} sem autenticação -> 401 UNAUTHORIZED
        String updateJson = """
                {
                    "name": "Maria Silva",
                    "email": "maria.silva@empresa.com",
                    "active": false
                }
                """;
        mockMvc.perform(put("/api/responsibles/" + mariaId)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updateJson))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("UNAUTHORIZED"));

        // 7.1 PUT com autenticação -> 200 OK (soft delete / inativação)
        mockMvc.perform(put("/api/responsibles/" + mariaId)
                        .header("Authorization", authHeader)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(updateJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Maria Silva"))
                .andExpect(jsonPath("$.email").value("maria.silva@empresa.com"))
                .andExpect(jsonPath("$.active").value(false));

        // 8. Tentar logar com usuário inativo -> 401 BAD_CREDENTIALS
        String mariaInativaLoginJson = """
                {
                    "email": "maria.silva@empresa.com",
                    "password": "senhaForte123"
                }
                """;
        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(mariaInativaLoginJson))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("BAD_CREDENTIALS"));

        // 9. DELETE /api/responsibles/{id} -> 405 Method Not Allowed (sem exclusão física)
        mockMvc.perform(delete("/api/responsibles/" + mariaId)
                        .header("Authorization", authHeader))
                .andExpect(status().isMethodNotAllowed());
    }
}
