package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.openapi;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.AbstractIntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

import static org.hamcrest.Matchers.containsString;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@AutoConfigureMockMvc
class OpenApiIntegrationTest extends AbstractIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("Deve disponibilizar a documentação OpenAPI v3 sem autenticação")
    void shouldReturnOpenApiDocumentationWithoutAuthentication() throws Exception {
        mockMvc.perform(get("/v3/api-docs"))
                .andExpect(status().isOk())
                .andExpect(content().string(containsString("Player Contabilidade - API de Gestão de Obrigações Fiscais")))
                .andExpect(content().string(containsString("bearerAuth")))
                .andExpect(content().string(containsString("/api/auth/login")))
                .andExpect(content().string(containsString("/api/companies")))
                .andExpect(content().string(containsString("/api/obligations")))
                .andExpect(content().string(containsString("/api/attachments/{attachmentId}/download")));
    }

    @Test
    @DisplayName("Deve carregar o Swagger UI index sem autenticação")
    void shouldLoadSwaggerUiIndexWithoutAuthentication() throws Exception {
        mockMvc.perform(get("/swagger-ui/index.html"))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("Deve permitir acesso ao redirecionador /swagger-ui.html")
    void shouldAllowAccessToSwaggerUiHtmlRedirect() throws Exception {
        mockMvc.perform(get("/swagger-ui.html"))
                .andExpect(status().is3xxRedirection());
    }
}
