package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.security;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;

import static org.assertj.core.api.Assertions.assertThat;

class CorsConfigurationTest {

    @Test
    @DisplayName("Deve permitir origens locais e configurar métodos, headers e credenciais")
    void shouldConfigureCorsCorrectly() {
        RestAuthenticationEntryPoint entryPoint = new RestAuthenticationEntryPoint();
        SecurityConfig securityConfig = new SecurityConfig(entryPoint, "http://localhost:*,http://127.0.0.1:*");

        CorsConfigurationSource source = securityConfig.corsConfigurationSource();
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/companies");

        CorsConfiguration config = source.getCorsConfiguration(request);

        assertThat(config).isNotNull();
        assertThat(config.getAllowCredentials()).isTrue();
        assertThat(config.getAllowedOriginPatterns()).containsExactly("http://localhost:*", "http://127.0.0.1:*");
        assertThat(config.getAllowedMethods()).contains("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD");
        assertThat(config.getAllowedHeaders()).contains("*");
        assertThat(config.getExposedHeaders()).contains("Authorization", "Content-Disposition", "Location");
        assertThat(config.getMaxAge()).isEqualTo(3600L);
    }

    @Test
    @DisplayName("Deve ignorar entradas vazias na lista de origens configuradas")
    void shouldFilterEmptyOrigins() {
        RestAuthenticationEntryPoint entryPoint = new RestAuthenticationEntryPoint();
        SecurityConfig securityConfig = new SecurityConfig(entryPoint, "http://localhost:* , , http://127.0.0.1:* ");

        CorsConfigurationSource source = securityConfig.corsConfigurationSource();
        CorsConfiguration config = source.getCorsConfiguration(new MockHttpServletRequest("GET", "/api/responsibles"));

        assertThat(config).isNotNull();
        assertThat(config.getAllowedOriginPatterns()).containsExactly("http://localhost:*", "http://127.0.0.1:*");
    }
}

