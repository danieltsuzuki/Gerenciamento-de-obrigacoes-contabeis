package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.service.AuthService;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.mapper.ResponsibleMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BadCredentialsException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.security.JwtService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.boot.test.system.CapturedOutput;
import org.springframework.boot.test.system.OutputCaptureExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith({MockitoExtension.class, OutputCaptureExtension.class})
class SecurityLoggingTest {

    @Mock
    private ResponsibleRepository responsibleRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    private final ResponsibleMapper responsibleMapper = new ResponsibleMapper();

    @Test
    @DisplayName("SPEC-036: Tentativa de login com senha incorreta nunca deve exibir a senha no log")
    void shouldNotLogSensitivePasswordOnFailedLogin(CapturedOutput output) {
        AuthService authService = new AuthService(responsibleRepository, passwordEncoder, jwtService, responsibleMapper);

        String secretPlainPassword = "super-secret-password-xyz-987";
        Responsible user = new Responsible();
        user.setId(10L);
        user.setEmail("usuario@empresa.com");
        user.setPasswordHash("hashed_value");
        user.setActive(true);

        when(responsibleRepository.findByEmail("usuario@empresa.com")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches(secretPlainPassword, "hashed_value")).thenReturn(false);

        LoginRequest request = new LoginRequest("usuario@empresa.com", secretPlainPassword);

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(BadCredentialsException.class);

        String logs = output.getAll();
        assertThat(logs).doesNotContain(secretPlainPassword);
        assertThat(logs).contains("Authentication failed - invalid password");
    }
}

