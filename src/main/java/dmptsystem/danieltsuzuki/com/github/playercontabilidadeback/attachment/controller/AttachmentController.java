package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto.AttachmentResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto.DownloadedFile;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.service.AttachmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.nio.charset.StandardCharsets;
import java.util.List;

@RestController
@RequestMapping("/api")
@Tag(name = "Anexos", description = "Operações para upload, listagem e download seguro de arquivos vinculados a obrigações")
public class AttachmentController {

    private final AttachmentService attachmentService;

    public AttachmentController(AttachmentService attachmentService) {
        this.attachmentService = attachmentService;
    }

    @PostMapping(value = "/obligations/{id}/attachments", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Realiza upload de anexo para a obrigação", description = "Armazena o arquivo no sistema de arquivos seguro e persiste seus metadados no banco. Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Anexo enviado e registrado com sucesso"),
            @ApiResponse(responseCode = "400", description = "Arquivo vazio, corrompido ou excedendo o limite de 10MB"),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "404", description = "Obrigação não encontrada")
    })
    public AttachmentResponse upload(
            @Parameter(description = "Identificador único da obrigação", example = "1")
            @PathVariable Long id,
            @Parameter(description = "Arquivo multipart/form-data a ser enviado", required = true)
            @RequestParam("file") MultipartFile file
    ) {
        return attachmentService.upload(id, file);
    }

    @GetMapping("/obligations/{id}/attachments")
    @Operation(summary = "Lista anexos de uma obrigação", description = "Retorna os metadados de todos os arquivos anexados à obrigação informada. Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Lista de anexos retornada com sucesso"),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "404", description = "Obrigação não encontrada")
    })
    public List<AttachmentResponse> listByObligation(
            @Parameter(description = "Identificador único da obrigação", example = "1")
            @PathVariable Long id
    ) {
        return attachmentService.findByObligationId(id);
    }

    @GetMapping("/attachments/{attachmentId}/download")
    @Operation(summary = "Download de arquivo anexo", description = "Recupera o arquivo físico armazenado para download binário via streaming. Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Download iniciado com sucesso",
                    content = @Content(mediaType = MediaType.APPLICATION_OCTET_STREAM_VALUE,
                            schema = @Schema(type = "string", format = "binary"))),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "404", description = "Metadados do anexo ou arquivo físico não encontrados")
    })
    public ResponseEntity<Resource> download(
            @Parameter(description = "Identificador único do anexo", example = "1")
            @PathVariable Long attachmentId
    ) {
        DownloadedFile downloaded = attachmentService.download(attachmentId);

        ContentDisposition disposition = ContentDisposition.attachment()
                .filename(downloaded.originalFilename(), StandardCharsets.UTF_8)
                .build();

        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(downloaded.contentType()))
                .contentLength(downloaded.size())
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition.toString())
                .body(downloaded.resource());
    }
}
