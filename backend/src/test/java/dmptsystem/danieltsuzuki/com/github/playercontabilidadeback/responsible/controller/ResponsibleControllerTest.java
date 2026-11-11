package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.CreateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.UpdateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.service.ResponsibleService;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.DuplicateResourceException;
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

import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(ResponsibleController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class ResponsibleControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private ResponsibleService responsibleService;

    @Test
    @DisplayName("GET /api/responsibles deve retornar 200 OK e lista paginada")
    void shouldReturnPaginatedList() throws Exception {
        Page<ResponsibleResponse> page = new PageImpl<>(List.of(
                new ResponsibleResponse(1L, "Carlos", "carlos@empresa.com", true, LocalDateTime.now(), LocalDateTime.now())
        ));
        when(responsibleService.findAll(any(), any())).thenReturn(page);

        mockMvc.perform(get("/api/responsibles"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].name").value("Carlos"));
    }

    @Test
    @DisplayName("GET /api/responsibles/{id} deve retornar 200 OK quando responsável existir")
    void shouldReturnResponsibleById() throws Exception {
        ResponsibleResponse response = new ResponsibleResponse(1L, "Carlos", "carlos@empresa.com", true, LocalDateTime.now(), LocalDateTime.now());
        when(responsibleService.findById(1L)).thenReturn(response);

        mockMvc.perform(get("/api/responsibles/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Carlos"));
    }

    @Test
    @DisplayName("GET /api/responsibles/{id} deve retornar 404 Not Found quando não existir")
    void shouldReturn404WhenNotFound() throws Exception {
        when(responsibleService.findById(99L)).thenThrow(new NotFoundException("Responsável", 99L));

        mockMvc.perform(get("/api/responsibles/99"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));
    }

    @Test
    @DisplayName("POST /api/responsibles deve criar com 201 CREATED")
    void shouldCreateResponsibleSuccessfully() throws Exception {
        ResponsibleResponse response = new ResponsibleResponse(1L, "Carlos", "carlos@empresa.com", true, LocalDateTime.now(), LocalDateTime.now());
        when(responsibleService.create(any(CreateResponsibleRequest.class))).thenReturn(response);

        String body = """
                {
                    "name": "Carlos",
                    "email": "carlos@empresa.com",
                    "password": "senhaSegura123",
                    "active": true
                }
                """;

        mockMvc.perform(post("/api/responsibles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.name").value("Carlos"));
    }

    @Test
    @DisplayName("POST /api/responsibles com dados inválidos retorna 400 VALIDATION_ERROR")
    void shouldReturn400OnInvalidData() throws Exception {
        String body = """
                {
                    "name": "",
                    "email": "invalido",
                    "password": ""
                }
                """;

        mockMvc.perform(post("/api/responsibles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    @DisplayName("POST /api/responsibles com e-mail duplicado retorna 409 DUPLICATE_EMAIL")
    void shouldReturn409OnDuplicateEmail() throws Exception {
        when(responsibleService.create(any(CreateResponsibleRequest.class)))
                .thenThrow(new DuplicateResourceException("DUPLICATE_EMAIL", "E-mail já cadastrado para outro responsável."));

        String body = """
                {
                    "name": "Carlos",
                    "email": "carlos@empresa.com",
                    "password": "senhaSegura123",
                    "active": true
                }
                """;

        mockMvc.perform(post("/api/responsibles")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.code").value("DUPLICATE_EMAIL"));
    }

    @Test
    @DisplayName("PUT /api/responsibles/{id} deve atualizar com 200 OK")
    void shouldUpdateResponsibleSuccessfully() throws Exception {
        ResponsibleResponse response = new ResponsibleResponse(1L, "Carlos Atualizado", "carlos@empresa.com", true, LocalDateTime.now(), LocalDateTime.now());
        when(responsibleService.update(eq(1L), any(UpdateResponsibleRequest.class))).thenReturn(response);

        String body = """
                {
                    "name": "Carlos Atualizado",
                    "email": "carlos@empresa.com",
                    "active": true
                }
                """;

        mockMvc.perform(put("/api/responsibles/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(body))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Carlos Atualizado"));
    }

    @Test
    @DisplayName("GET /api/responsibles com termo de busca q deve retornar 200 OK")
    void shouldReturn200WhenSearchingResponsibles() throws Exception {
        ResponsibleResponse response = new ResponsibleResponse(1L, "Carlos Contador", "carlos@empresa.com", true, LocalDateTime.now(), LocalDateTime.now());
        when(responsibleService.findAll(eq(true), eq("carlos"), any(PageRequest.class)))
                .thenReturn(new PageImpl<>(List.of(response)));

        mockMvc.perform(get("/api/responsibles?active=true&q=carlos&page=0&size=10"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.content[0].name").value("Carlos Contador"));
    }

    @Test
    @DisplayName("GET /api/responsibles com q excedendo 100 caracteres deve retornar 400 VALIDATION_ERROR")
    void shouldReturn400WhenSearchQueryTooLong() throws Exception {
        when(responsibleService.findAll(any(), eq("c".repeat(101)), any()))
                .thenThrow(new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.SearchQueryTooLongException(
                        "O parâmetro de busca 'q' não pode exceder 100 caracteres."
                ));

        mockMvc.perform(get("/api/responsibles?q=" + "c".repeat(101)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"));
    }

    @Test
    @DisplayName("DELETE /api/responsibles/{id} deve retornar 405 Method Not Allowed")
    void shouldReturn405OnDelete() throws Exception {
        mockMvc.perform(delete("/api/responsibles/1"))
                .andExpect(status().isMethodNotAllowed());
    }
}
