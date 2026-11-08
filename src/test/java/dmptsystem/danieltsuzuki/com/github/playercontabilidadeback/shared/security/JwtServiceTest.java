package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.security;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class JwtServiceTest {

    private JwtService jwtService;

    @BeforeEach
    void setUp() {
        jwtService = new JwtService(
                "chave-secreta-de-teste-muito-longa-com-mais-de-32-bytes-segura-123456",
                3600000L
        );
    }

    @Test
    @DisplayName("Deve gerar token JWT e extrair email com sucesso")
    void shouldGenerateAndExtractEmail() {
        Responsible responsible = new Responsible();
        responsible.setId(10L);
        responsible.setName("Carlos Silva");
        responsible.setEmail("carlos@empresa.com");

        String token = jwtService.generateToken(responsible);

        assertThat(token).isNotBlank();
        assertThat(jwtService.extractEmail(token)).isEqualTo("carlos@empresa.com");
        assertThat(jwtService.isTokenValid(token)).isTrue();
        assertThat(jwtService.isTokenValid(token, "carlos@empresa.com")).isTrue();
        assertThat(jwtService.isTokenValid(token, "outro@empresa.com")).isFalse();
    }

    @Test
    @DisplayName("Deve invalidar token malformado")
    void shouldInvalidateMalformedToken() {
        assertThat(jwtService.isTokenValid("token-invalido")).isFalse();
        assertThat(jwtService.isTokenValid("token-invalido", "teste@empresa.com")).isFalse();
    }
}

