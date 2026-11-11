package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanySummaryResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.CreateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationDetailResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationListItemResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.UpdateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.service.ObligationService;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleSummaryResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BusinessRuleException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.GlobalExceptionHandler;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.MediaType;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ObligationController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class ObligationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ObligationService obligationService;

    private final CompanySummaryResponse companySummary = new CompanySummaryResponse(
            1L, "Empresa Modelo", "Modelo", "33000167000101", true
    );

    private final ResponsibleSummaryResponse responsibleSummary = new ResponsibleSummaryResponse(
            2L, "Carlos Silva", "carlos@empresa.com", true
    );

    @Test
    @DisplayName("POST /api/obligations cria obrigação com sucesso -> 201 Created")
    void shouldCreateObligation() throws Exception {
        ObligationDetailResponse response = new ObligationDetailResponse(
                10L, companySummary, responsibleSummary, "DEFIS 2026", "Descrição",
                ObligationStatus.PENDING, LocalDate.of(2026, 3, 31), 0L, null, LocalDateTime.now(), LocalDateTime.now()
        );

        when(obligationService.create(any(CreateObligationRequest.class))).thenReturn(response);

        String body = """
                {
                    "companyId": 1,
                    "responsibleId": 2,
                    "title": "DEFIS 2026",
                    "description": "Descrição",
                    "dueDate": "2026-03-31"
                }
                """;

        mockMvc.perform(post("/api/obligations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.title").value("DEFIS 2026"))
                .andExpect(jsonPath("$.status").value("PENDING"))
                .andExpect(jsonPath("$.attachmentCount").value(0))
                .andExpect(jsonPath("$.company.id").value(1))
                .andExpect(jsonPath("$.responsible.id").value(2));
    }

    @Test
    @DisplayName("POST /api/obligations com dados inválidos retorna 400 VALIDATION_ERROR")
    void shouldReturn400OnInvalidPayload() throws Exception {
        String body = """
                {
                    "companyId": null,
                    "responsibleId": null,
                    "title": "",
                    "dueDate": null
                }
                """;

        mockMvc.perform(post("/api/obligations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    @DisplayName("POST /api/obligations com empresa inativa retorna 422 COMPANY_INACTIVE")
    void shouldReturn422OnCompanyInactive() throws Exception {
        when(obligationService.create(any(CreateObligationRequest.class)))
                .thenThrow(new BusinessRuleException("COMPANY_INACTIVE", "Empresa inativa não pode receber novas obrigações."));

        String body = """
                {
                    "companyId": 1,
                    "responsibleId": 2,
                    "title": "DEFIS 2026",
                    "dueDate": "2026-03-31"
                }
                """;

        mockMvc.perform(post("/api/obligations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("COMPANY_INACTIVE"));
    }

    @Test
    @DisplayName("GET /api/obligations retorna listagem paginada com contagem de anexos -> 200 OK")
    void shouldListObligations() throws Exception {
        ObligationListItemResponse item = new ObligationListItemResponse(
                10L, companySummary, responsibleSummary, "DEFIS 2026",
                ObligationStatus.PENDING, LocalDate.of(2026, 3, 31), 2L, LocalDateTime.now(), null
        );
        Page<ObligationListItemResponse> page = new PageImpl<>(List.of(item));

        when(obligationService.findAll(any(), any(), any(), any(), any(), any())).thenReturn(page);

        mockMvc.perform(get("/api/obligations?page=0&size=10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].id").value(10))
                .andExpect(jsonPath("$.content[0].attachmentCount").value(2))
                .andExpect(jsonPath("$.content[0].status").value("PENDING"));
    }

    @Test
    @DisplayName("GET /api/obligations/{id} retorna detalhes da obrigação -> 200 OK")
    void shouldGetObligationById() throws Exception {
        ObligationDetailResponse response = new ObligationDetailResponse(
                10L, companySummary, responsibleSummary, "DEFIS 2026", "Descrição",
                ObligationStatus.PENDING, LocalDate.of(2026, 3, 31), 1L, null, LocalDateTime.now(), LocalDateTime.now()
        );

        when(obligationService.findById(10L)).thenReturn(response);

        mockMvc.perform(get("/api/obligations/10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.attachmentCount").value(1));
    }

    @Test
    @DisplayName("GET /api/obligations/{id} inexistente retorna 404 NOT_FOUND")
    void shouldReturn404WhenNotFound() throws Exception {
        when(obligationService.findById(99L)).thenThrow(new NotFoundException("Obrigação", 99L));

        mockMvc.perform(get("/api/obligations/99"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));
    }

    @Test
    @DisplayName("PUT /api/obligations/{id} atualiza obrigação -> 200 OK")
    void shouldUpdateObligation() throws Exception {
        ObligationDetailResponse response = new ObligationDetailResponse(
                10L, companySummary, responsibleSummary, "DEFIS 2026 Alterado", "Descrição",
                ObligationStatus.IN_PROGRESS, LocalDate.of(2026, 4, 15), 1L, null, LocalDateTime.now(), LocalDateTime.now()
        );

        when(obligationService.update(eq(10L), any(UpdateObligationRequest.class))).thenReturn(response);

        String body = """
                {
                    "companyId": 1,
                    "responsibleId": 2,
                    "title": "DEFIS 2026 Alterado",
                    "description": "Descrição",
                    "dueDate": "2026-04-15",
                    "status": "IN_PROGRESS"
                }
                """;

        mockMvc.perform(put("/api/obligations/10")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("DEFIS 2026 Alterado"))
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"));
    }

    @Test
    @DisplayName("DELETE /api/obligations/{id} deve retornar 405 Method Not Allowed")
    void shouldReturn405OnDelete() throws Exception {
        mockMvc.perform(delete("/api/obligations/10"))
                .andExpect(status().isMethodNotAllowed());
    }

    @Test
    @DisplayName("PATCH /api/obligations/{id}/status atualiza status com sucesso -> 200 OK")
    void shouldUpdateStatusSuccessfully() throws Exception {
        ObligationDetailResponse response = new ObligationDetailResponse(
                10L, companySummary, responsibleSummary, "DEFIS 2026", "Descrição",
                ObligationStatus.IN_PROGRESS, LocalDate.of(2026, 3, 31), 0L, null, LocalDateTime.now(), LocalDateTime.now()
        );

        when(obligationService.updateStatus(eq(10L), eq(ObligationStatus.IN_PROGRESS))).thenReturn(response);

        String body = """
                {
                    "status": "IN_PROGRESS"
                }
                """;

        mockMvc.perform(patch("/api/obligations/10/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.status").value("IN_PROGRESS"));
    }

    @Test
    @DisplayName("PATCH /api/obligations/{id}/status com transição inválida retorna 422 INVALID_STATUS_TRANSITION")
    void shouldReturn422OnInvalidStatusTransition() throws Exception {
        when(obligationService.updateStatus(eq(10L), eq(ObligationStatus.COMPLETED)))
                .thenThrow(new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.exception.InvalidStatusTransitionException(
                        ObligationStatus.PENDING, ObligationStatus.COMPLETED
                ));

        String body = """
                {
                    "status": "COMPLETED"
                }
                """;

        mockMvc.perform(patch("/api/obligations/10/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.code").value("INVALID_STATUS_TRANSITION"));
    }

    @Test
    @DisplayName("PATCH /api/obligations/{id}/status com status ausente retorna 400 VALIDATION_ERROR")
    void shouldReturn400WhenStatusNull() throws Exception {
        String body = """
                {
                    "status": null
                }
                """;

        mockMvc.perform(patch("/api/obligations/10/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    @DisplayName("PATCH /api/obligations/{id}/status em obrigação inexistente retorna 404 NOT_FOUND")
    void shouldReturn404WhenNotFoundOnUpdateStatus() throws Exception {
        when(obligationService.updateStatus(eq(999L), eq(ObligationStatus.IN_PROGRESS)))
                .thenThrow(new NotFoundException("Obrigação", 999L));

        String body = """
                {
                    "status": "IN_PROGRESS"
                }
                """;

        mockMvc.perform(patch("/api/obligations/999/status")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));
    }

    @Test
    @DisplayName("GET /api/obligations com termo de busca q deve retornar 200 OK")
    void shouldReturn200WhenSearchingObligations() throws Exception {
        ObligationListItemResponse item = new ObligationListItemResponse(
                1L,
                new CompanySummaryResponse(1L, "Empresa LTDA", "Empresa", "11222333000181", true),
                new ResponsibleSummaryResponse(2L, "Carlos", "carlos@empresa.com", true),
                "Declaração DCTF",
                ObligationStatus.PENDING,
                LocalDate.of(2026, 11, 30),
                0L,
                LocalDateTime.now(),
                null
        );

        when(obligationService.findAll(any(), any(), any(), any(), any(), eq("dctf"), any(PageRequest.class)))
                .thenReturn(new PageImpl<>(List.of(item)));

        mockMvc.perform(get("/api/obligations?q=dctf&page=0&size=10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].title").value("Declaração DCTF"));
    }

    @Test
    @DisplayName("GET /api/obligations com q excedendo 100 caracteres deve retornar 400 VALIDATION_ERROR")
    void shouldReturn400WhenSearchQueryTooLong() throws Exception {
        when(obligationService.findAll(any(), any(), any(), any(), any(), eq("d".repeat(101)), any()))
                .thenThrow(new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.SearchQueryTooLongException(
                        "O parâmetro de busca 'q' não pode exceder 100 caracteres."
                ));

        mockMvc.perform(get("/api/obligations?q=" + "d".repeat(101)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    @DisplayName("SPEC-035: GET /api/obligations/{id}/history retorna lista cronológica -> 200 OK")
    void shouldReturnObligationHistory() throws Exception {
        dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationStatusHistoryResponse item1 =
                new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationStatusHistoryResponse(
                        1L, 10L, null, ObligationStatus.PENDING, responsibleSummary, LocalDateTime.of(2026, 11, 1, 10, 0)
                );
        dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationStatusHistoryResponse item2 =
                new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationStatusHistoryResponse(
                        2L, 10L, ObligationStatus.PENDING, ObligationStatus.IN_PROGRESS, responsibleSummary, LocalDateTime.of(2026, 11, 5, 14, 30)
                );

        when(obligationService.findHistoryByObligationId(10L)).thenReturn(List.of(item1, item2));

        mockMvc.perform(get("/api/obligations/10/history"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].fromStatus").doesNotExist())
                .andExpect(jsonPath("$[0].toStatus").value("PENDING"))
                .andExpect(jsonPath("$[0].changedBy.name").value("Carlos Silva"))
                .andExpect(jsonPath("$[1].fromStatus").value("PENDING"))
                .andExpect(jsonPath("$[1].toStatus").value("IN_PROGRESS"));
    }

    @Test
    @DisplayName("SPEC-035: GET /api/obligations/{id}/history para obrigação inexistente -> 404 NOT_FOUND")
    void shouldReturn404WhenObligationNotFoundForHistory() throws Exception {
        when(obligationService.findHistoryByObligationId(999L))
                .thenThrow(new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException("Obrigação", 999L));

        mockMvc.perform(get("/api/obligations/999/history"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));
    }
}

