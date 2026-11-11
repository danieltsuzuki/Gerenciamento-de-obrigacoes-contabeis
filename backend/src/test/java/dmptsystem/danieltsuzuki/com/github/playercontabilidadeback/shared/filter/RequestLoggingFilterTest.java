package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.filter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.io.IOException;

import static org.assertj.core.api.Assertions.assertThat;

class RequestLoggingFilterTest {

    private final RequestLoggingFilter filter = new RequestLoggingFilter();

    @Test
    @DisplayName("SPEC-036: Deve gerar X-Request-Id quando requisição não contiver cabeçalho")
    void shouldGenerateRequestIdWhenNotPresent() throws ServletException, IOException {
        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/companies");
        MockHttpServletResponse response = new MockHttpServletResponse();

        final String[] mdcCapture = new String[1];
        FilterChain chain = (req, res) -> {
            mdcCapture[0] = MDC.get(RequestLoggingFilter.MDC_REQUEST_ID_KEY);
        };

        filter.doFilter(request, response, chain);

        String responseHeader = response.getHeader(RequestLoggingFilter.REQUEST_ID_HEADER);
        assertThat(responseHeader).isNotNull().isNotBlank();
        assertThat(mdcCapture[0]).isEqualTo(responseHeader);
        // Após a execução, o MDC deve estar limpo
        assertThat(MDC.get(RequestLoggingFilter.MDC_REQUEST_ID_KEY)).isNull();
    }

    @Test
    @DisplayName("SPEC-036: Deve propagar X-Request-Id existente recebido na requisição")
    void shouldPropagateExistingRequestId() throws ServletException, IOException {
        String customId = "trace-12345-custom";
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/obligations");
        request.addHeader(RequestLoggingFilter.REQUEST_ID_HEADER, customId);
        MockHttpServletResponse response = new MockHttpServletResponse();

        final String[] mdcCapture = new String[1];
        FilterChain chain = (req, res) -> {
            mdcCapture[0] = MDC.get(RequestLoggingFilter.MDC_REQUEST_ID_KEY);
        };

        filter.doFilter(request, response, chain);

        assertThat(response.getHeader(RequestLoggingFilter.REQUEST_ID_HEADER)).isEqualTo(customId);
        assertThat(mdcCapture[0]).isEqualTo(customId);
        assertThat(MDC.get(RequestLoggingFilter.MDC_REQUEST_ID_KEY)).isNull();
    }
}

