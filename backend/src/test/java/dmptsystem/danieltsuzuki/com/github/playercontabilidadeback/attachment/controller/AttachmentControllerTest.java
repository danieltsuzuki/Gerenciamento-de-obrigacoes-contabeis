package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto.AttachmentResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto.DownloadedFile;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.exception.InvalidFileException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.service.AttachmentService;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.GlobalExceptionHandler;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.header;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AttachmentController.class)
@AutoConfigureMockMvc(addFilters = false)
@Import(GlobalExceptionHandler.class)
class AttachmentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private AttachmentService attachmentService;

    @Test
    @DisplayName("POST /api/obligations/{id}/attachments com sucesso retorna 201 Created")
    void shouldUploadAttachmentSuccessfully() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file",
                "declaracao.pdf",
                "application/pdf",
                "conteudo binario".getBytes()
        );

        AttachmentResponse response = new AttachmentResponse(
                10L, 1L, "declaracao.pdf", "application/pdf", 16L, LocalDateTime.now()
        );

        when(attachmentService.upload(eq(1L), any())).thenReturn(response);

        mockMvc.perform(multipart("/api/obligations/1/attachments").file(file))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.name").value("declaracao.pdf"))
                .andExpect(jsonPath("$.contentType").value("application/pdf"))
                .andExpect(jsonPath("$.size").value(16));
    }

    @Test
    @DisplayName("POST /api/obligations/{id}/attachments com arquivo vazio retorna 400 VALIDATION_ERROR")
    void shouldReturn400OnEmptyFile() throws Exception {
        MockMultipartFile file = new MockMultipartFile(
                "file", "vazio.pdf", "application/pdf", new byte[0]
        );

        when(attachmentService.upload(eq(1L), any()))
                .thenThrow(new InvalidFileException("O arquivo não pode ser nulo ou vazio."));

        mockMvc.perform(multipart("/api/obligations/1/attachments").file(file))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.message").value("O arquivo não pode ser nulo ou vazio."));
    }

    @Test
    @DisplayName("GET /api/obligations/{id}/attachments retorna lista de anexos -> 200 OK")
    void shouldListAttachmentsForObligation() throws Exception {
        AttachmentResponse a1 = new AttachmentResponse(
                10L, 1L, "guia.pdf", "application/pdf", 100L, LocalDateTime.now()
        );
        AttachmentResponse a2 = new AttachmentResponse(
                11L, 1L, "recibo.png", "image/png", 200L, LocalDateTime.now()
        );

        when(attachmentService.findByObligationId(1L)).thenReturn(List.of(a1, a2));

        mockMvc.perform(get("/api/obligations/1/attachments"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].name").value("guia.pdf"))
                .andExpect(jsonPath("$[1].name").value("recibo.png"));
    }

    @Test
    @DisplayName("GET /api/attachments/{attachmentId}/download retorna fluxo de bytes e cabeçalhos corretos -> 200 OK")
    void shouldDownloadAttachmentSuccessfully() throws Exception {
        byte[] bytes = "conteudo binario da guia darf".getBytes();
        ByteArrayResource resource = new ByteArrayResource(bytes);
        DownloadedFile downloadedFile = new DownloadedFile(resource, "darf_novembro.pdf", "application/pdf", bytes.length);

        when(attachmentService.download(10L)).thenReturn(downloadedFile);

        mockMvc.perform(get("/api/attachments/10/download"))
                .andExpect(status().isOk())
                .andExpect(header().string(HttpHeaders.CONTENT_TYPE, "application/pdf"))
                .andExpect(header().string(HttpHeaders.CONTENT_DISPOSITION, containsString("attachment; filename=\"darf_novembro.pdf\"")))
                .andExpect(content().bytes(bytes));
    }

    @Test
    @DisplayName("GET /api/attachments/{attachmentId}/download com ID inexistente retorna 404 NOT_FOUND")
    void shouldReturn404WhenDownloadingNonExistent() throws Exception {
        when(attachmentService.download(999L)).thenThrow(new NotFoundException("Anexo", 999L));

        mockMvc.perform(get("/api/attachments/999/download"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.code").value("NOT_FOUND"));
    }
}

