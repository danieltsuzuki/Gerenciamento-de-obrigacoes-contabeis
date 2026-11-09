package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.service.AuthService;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.CreateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.service.ResponsibleService;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BadCredentialsException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.DuplicateResourceException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.GlobalExceptionHandler;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private AuthService authService;

    @MockitoBean
    private ResponsibleService responsibleService;

    @Test
    @DisplayName("POST /api/auth/login com credenciais válidas retorna 200 e token de 30 min (1800s)")
    void shouldLoginSuccessfully() throws Exception {
        ResponsibleResponse user = new ResponsibleResponse(1L, "Admin", "admin@empresa.com", true, LocalDateTime.now(), LocalDateTime.now());
        LoginResponse response = new LoginResponse("mocked-jwt-token", "Bearer", 1800, user);

        when(authService.login(any(LoginRequest.class))).thenReturn(response);

        String requestBody = """
                {
                    "email": "admin@empresa.com",
                    "password": "correctPassword"
                }
                """;

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.token").value("mocked-jwt-token"))
                .andExpect(jsonPath("$.tokenType").value("Bearer"))
                .andExpect(jsonPath("$.expiresIn").value(1800))
                .andExpect(jsonPath("$.user.email").value("admin@empresa.com"));
    }

    @Test
    @DisplayName("POST /api/auth/login com credenciais inválidas retorna 401 UNAUTHORIZED")
    void shouldReturn401OnBadCredentials() throws Exception {
        when(authService.login(any(LoginRequest.class))).thenThrow(new BadCredentialsException("Credenciais inválidas."));

        String requestBody = """
                {
                    "email": "admin@empresa.com",
                    "password": "wrongPassword"
                }
                """;

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("BAD_CREDENTIALS"))
                .andExpect(jsonPath("$.message").value("Credenciais inválidas."));
    }

    @Test
    @DisplayName("POST /api/auth/login com campos inválidos retorna 400 VALIDATION_ERROR")
    void shouldReturn400OnValidationFailure() throws Exception {
        String requestBody = """
                {
                    "email": "formato-invalido",
                    "password": ""
                }
                """;

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    @DisplayName("POST /api/auth/register cria usuário com 201 CREATED")
    void shouldRegisterSuccessfully() throws Exception {
        ResponsibleResponse response = new ResponsibleResponse(2L, "Novo Usuário", "novo@empresa.com", true, LocalDateTime.now(), LocalDateTime.now());
        when(responsibleService.create(any(CreateResponsibleRequest.class))).thenReturn(response);

        String requestBody = """
                {
                    "name": "Novo Usuário",
                    "email": "novo@empresa.com",
                    "password": "senhaSegura123",
                    "active": true
                }
                """;

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(2))
                .andExpect(jsonPath("$.name").value("Novo Usuário"))
                .andExpect(jsonPath("$.email").value("novo@empresa.com"));
    }

    @Test
    @DisplayName("POST /api/auth/register com e-mail duplicado retorna 409 DUPLICATE_EMAIL")
    void shouldReturn409WhenEmailAlreadyExistsOnRegister() throws Exception {
        when(responsibleService.create(any(CreateResponsibleRequest.class)))
                .thenThrow(new DuplicateResourceException("DUPLICATE_EMAIL", "E-mail já cadastrado para outro responsável."));

        String requestBody = """
                {
                    "name": "Novo Usuário",
                    "email": "duplicado@empresa.com",
                    "password": "senhaSegura123",
                    "active": true
                }
                """;

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(requestBody))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DUPLICATE_EMAIL"));
    }
}
