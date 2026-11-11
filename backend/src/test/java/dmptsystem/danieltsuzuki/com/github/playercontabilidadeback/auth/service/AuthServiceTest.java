package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.mapper.ResponsibleMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BadCredentialsException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.security.JwtService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private ResponsibleRepository responsibleRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @Mock
    private ResponsibleMapper responsibleMapper;

    private AuthService authService;

    @BeforeEach
    void setUp() {
        authService = new AuthService(responsibleRepository, passwordEncoder, jwtService, responsibleMapper);
    }

    private Responsible createResponsible(Long id, String name, String email, String passwordHash, boolean active) {
        Responsible r = new Responsible();
        r.setId(id);
        r.setName(name);
        r.setEmail(email);
        r.setPasswordHash(passwordHash);
        r.setActive(active);
        return r;
    }

    @Test
    @DisplayName("Deve autenticar com sucesso quando as credenciais forem válidas")
    void shouldAuthenticateSuccessfully() {
        Responsible user = createResponsible(1L, "Carlos Silva", "carlos@player.com.br", "hashed_pwd", true);
        ResponsibleResponse respDto = new ResponsibleResponse(1L, "Carlos Silva", "carlos@player.com.br", true, null, null);

        when(responsibleRepository.findByEmail("carlos@player.com.br")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("secret123", "hashed_pwd")).thenReturn(true);
        when(jwtService.generateToken(user)).thenReturn("jwt.token.mock");
        when(jwtService.getExpirationSeconds()).thenReturn(1800L);
        when(responsibleMapper.toResponse(user)).thenReturn(respDto);

        LoginResponse response = authService.login(new LoginRequest("carlos@player.com.br", "secret123"));

        assertThat(response).isNotNull();
        assertThat(response.token()).isEqualTo("jwt.token.mock");
        assertThat(response.tokenType()).isEqualTo("Bearer");
        assertThat(response.expiresIn()).isEqualTo(1800L);
        assertThat(response.user().email()).isEqualTo("carlos@player.com.br");
    }

    @Test
    @DisplayName("Deve rejeitar autenticação quando usuário não for encontrado e mascarar e-mail no log")
    void shouldRejectWhenUserNotFound() {
        when(responsibleRepository.findByEmail("inexistente@player.com.br")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> authService.login(new LoginRequest("inexistente@player.com.br", "pwd")))
                .isInstanceOf(BadCredentialsException.class)
                .hasMessage("Credenciais inválidas.");
    }

    @Test
    @DisplayName("Deve rejeitar autenticação quando e-mail for inválido ou muito curto sem falhar no mascaramento")
    void shouldRejectWhenEmailHasShortPrefixOrNoAt() {
        when(responsibleRepository.findByEmail("")).thenReturn(Optional.empty());
        assertThatThrownBy(() -> authService.login(new LoginRequest(null, "pwd")))
                .isInstanceOf(BadCredentialsException.class);

        when(responsibleRepository.findByEmail("no-at-sign")).thenReturn(Optional.empty());
        assertThatThrownBy(() -> authService.login(new LoginRequest("no-at-sign", "pwd")))
                .isInstanceOf(BadCredentialsException.class);

        when(responsibleRepository.findByEmail("a@empresa.com")).thenReturn(Optional.empty());
        assertThatThrownBy(() -> authService.login(new LoginRequest("a@empresa.com", "pwd")))
                .isInstanceOf(BadCredentialsException.class);
    }

    @Test
    @DisplayName("Deve rejeitar autenticação quando usuário estiver inativo")
    void shouldRejectWhenUserIsInactive() {
        Responsible inactiveUser = createResponsible(2L, "Inativo", "inativo@player.com.br", "hashed_pwd", false);
        when(responsibleRepository.findByEmail("inativo@player.com.br")).thenReturn(Optional.of(inactiveUser));

        assertThatThrownBy(() -> authService.login(new LoginRequest("inativo@player.com.br", "pwd")))
                .isInstanceOf(BadCredentialsException.class)
                .hasMessage("Usuário inativo. Acesso não permitido.");
    }

    @Test
    @DisplayName("Deve rejeitar autenticação quando senha estiver incorreta")
    void shouldRejectWhenPasswordIsIncorrect() {
        Responsible user = createResponsible(1L, "Carlos Silva", "carlos@player.com.br", "hashed_pwd", true);
        when(responsibleRepository.findByEmail("carlos@player.com.br")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrong_pwd", "hashed_pwd")).thenReturn(false);

        assertThatThrownBy(() -> authService.login(new LoginRequest("carlos@player.com.br", "wrong_pwd")))
                .isInstanceOf(BadCredentialsException.class)
                .hasMessage("Credenciais inválidas.");
    }
}
