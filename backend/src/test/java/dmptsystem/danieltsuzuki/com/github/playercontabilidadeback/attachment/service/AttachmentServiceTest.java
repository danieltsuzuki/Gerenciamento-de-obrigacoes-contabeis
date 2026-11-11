package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto.AttachmentResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.dto.DownloadedFile;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.entity.Attachment;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.exception.InvalidFileException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.mapper.AttachmentMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.repository.AttachmentRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.storage.FileStorage;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.Obligation;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository.ObligationRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BusinessRuleException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.mock.web.MockMultipartFile;

import java.io.InputStream;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AttachmentServiceTest {

    @Mock
    private AttachmentRepository attachmentRepository;

    @Mock
    private ObligationRepository obligationRepository;

    @Mock
    private FileStorage fileStorage;

    private final AttachmentMapper attachmentMapper = new AttachmentMapper();
    private final Clock clock = Clock.fixed(Instant.parse("2026-11-08T15:00:00Z"), ZoneOffset.UTC);

    private AttachmentService attachmentService;

    @BeforeEach
    void setUp() {
        attachmentService = new AttachmentService(
                attachmentRepository,
                obligationRepository,
                fileStorage,
                attachmentMapper,
                clock
        );
    }

    @Test
    @DisplayName("Deve fazer upload de anexo com sucesso e registrar metadados")
    void shouldUploadAttachmentSuccessfully() {
        Obligation obligation = new Obligation();
        when(obligationRepository.findById(1L)).thenReturn(Optional.of(obligation));

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "declaracao_irpj.pdf",
                "application/pdf",
                "dados do arquivo".getBytes()
        );

        when(fileStorage.store(any(InputStream.class), eq(1L), eq("declaracao_irpj.pdf")))
                .thenReturn("1/uuid-gerado.pdf");

        when(attachmentRepository.save(any(Attachment.class))).thenAnswer(invocation -> {
            Attachment a = invocation.getArgument(0);
            a.setId(100L);
            return a;
        });

        AttachmentResponse response = attachmentService.upload(1L, file);

        assertThat(response).isNotNull();
        assertThat(response.id()).isEqualTo(100L);
        assertThat(response.obligationId()).isEqualTo(obligation.getId());
        assertThat(response.name()).isEqualTo("declaracao_irpj.pdf");
        assertThat(response.contentType()).isEqualTo("application/pdf");
        assertThat(response.size()).isEqualTo(file.getSize());
        assertThat(response.uploadedAt()).isEqualTo(LocalDateTime.of(2026, 11, 8, 15, 0));

        verify(fileStorage).store(any(InputStream.class), eq(1L), eq("declaracao_irpj.pdf"));
        verify(attachmentRepository).save(any(Attachment.class));
    }

    @Test
    @DisplayName("Deve executar compensação excluindo arquivo em disco caso inserção no banco falhe")
    void shouldCompensateByDeletingPhysicalFileWhenDatabaseFails() {
        Obligation obligation = new Obligation();
        when(obligationRepository.findById(1L)).thenReturn(Optional.of(obligation));

        MockMultipartFile file = new MockMultipartFile(
                "file",
                "recibo.png",
                "image/png",
                "bytes da imagem".getBytes()
        );

        when(fileStorage.store(any(InputStream.class), eq(1L), eq("recibo.png")))
                .thenReturn("1/uuid-imagem.png");

        when(attachmentRepository.save(any(Attachment.class)))
                .thenThrow(new RuntimeException("Simulação de falha catastrófica de BD"));

        assertThatThrownBy(() -> attachmentService.upload(1L, file))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Simulação de falha catastrófica de BD");

        // Compensação: arquivo físico em disco deve ter sido excluído
        verify(fileStorage).delete("1/uuid-imagem.png");
    }

    @Test
    @DisplayName("Deve lançar NotFoundException ao tentar anexar em obrigação inexistente")
    void shouldThrowNotFoundExceptionWhenObligationDoesNotExist() {
        when(obligationRepository.findById(999L)).thenReturn(Optional.empty());

        MockMultipartFile file = new MockMultipartFile(
                "file", "doc.pdf", "application/pdf", "conteudo".getBytes()
        );

        assertThatThrownBy(() -> attachmentService.upload(999L, file))
                .isInstanceOf(NotFoundException.class);

        verifyNoInteractions(fileStorage);
        verifyNoInteractions(attachmentRepository);
    }

    @Test
    @DisplayName("Deve lançar InvalidFileException quando arquivo for vazio")
    void shouldThrowInvalidFileExceptionWhenFileIsEmpty() {
        Obligation obligation = new Obligation();
        when(obligationRepository.findById(1L)).thenReturn(Optional.of(obligation));

        MockMultipartFile file = new MockMultipartFile(
                "file", "vazio.pdf", "application/pdf", new byte[0]
        );

        assertThatThrownBy(() -> attachmentService.upload(1L, file))
                .isInstanceOf(InvalidFileException.class)
                .hasMessageContaining("não pode ser nulo ou vazio");

        verifyNoInteractions(fileStorage);
    }

    @Test
    @DisplayName("Deve lançar InvalidFileException quando nome do arquivo for em branco")
    void shouldThrowInvalidFileExceptionWhenFilenameIsBlank() {
        Obligation obligation = new Obligation();
        when(obligationRepository.findById(1L)).thenReturn(Optional.of(obligation));

        MockMultipartFile file = new MockMultipartFile(
                "file", "   ", "application/pdf", "conteudo".getBytes()
        );

        assertThatThrownBy(() -> attachmentService.upload(1L, file))
                .isInstanceOf(InvalidFileException.class)
                .hasMessageContaining("obrigatório");

        verifyNoInteractions(fileStorage);
    }

    @Test
    @DisplayName("Deve lançar InvalidFileException quando tipo MIME não for permitido")
    void shouldThrowInvalidFileExceptionWhenMimeTypeNotAllowed() {
        Obligation obligation = new Obligation();
        when(obligationRepository.findById(1L)).thenReturn(Optional.of(obligation));

        MockMultipartFile file = new MockMultipartFile(
                "file", "script.sh", "application/x-sh", "echo 'teste'".getBytes()
        );

        assertThatThrownBy(() -> attachmentService.upload(1L, file))
                .isInstanceOf(InvalidFileException.class)
                .hasMessageContaining("Tipo de arquivo não permitido");

        verifyNoInteractions(fileStorage);
    }

    @Test
    @DisplayName("Deve listar anexos de uma obrigação existente")
    void shouldFindAttachmentsByObligationIdSuccessfully() {
        when(obligationRepository.findById(5L)).thenReturn(Optional.of(new Obligation()));

        Attachment a1 = new Attachment();
        a1.setId(10L);
        a1.setName("arquivo1.pdf");
        a1.setContentType("application/pdf");
        a1.setSize(1024L);
        a1.setUploadedAt(LocalDateTime.now());

        Attachment a2 = new Attachment();
        a2.setId(11L);
        a2.setName("arquivo2.png");
        a2.setContentType("image/png");
        a2.setSize(2048L);
        a2.setUploadedAt(LocalDateTime.now());

        when(attachmentRepository.findByObligationId(5L)).thenReturn(List.of(a1, a2));

        List<AttachmentResponse> result = attachmentService.findByObligationId(5L);

        assertThat(result).hasSize(2);
        assertThat(result.get(0).name()).isEqualTo("arquivo1.pdf");
        assertThat(result.get(1).name()).isEqualTo("arquivo2.png");
    }

    @Test
    @DisplayName("Deve lançar NotFoundException ao listar anexos de obrigação inexistente")
    void shouldThrowNotFoundExceptionWhenListingForNonExistentObligation() {
        when(obligationRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> attachmentService.findByObligationId(99L))
                .isInstanceOf(NotFoundException.class);
    }

    @Test
    @DisplayName("Deve realizar download de anexo existente com sucesso")
    void shouldDownloadAttachmentSuccessfully() {
        Attachment attachment = new Attachment();
        attachment.setId(50L);
        attachment.setName("relatorio.pdf");
        attachment.setContentType("application/pdf");
        attachment.setSize(4096L);
        attachment.setStorageKey("5/uuid-relatorio.pdf");

        when(attachmentRepository.findById(50L)).thenReturn(Optional.of(attachment));

        Resource resource = new ByteArrayResource("conteudo do relatorio".getBytes());
        when(fileStorage.load("5/uuid-relatorio.pdf")).thenReturn(resource);

        DownloadedFile downloaded = attachmentService.download(50L);

        assertThat(downloaded).isNotNull();
        assertThat(downloaded.originalFilename()).isEqualTo("relatorio.pdf");
        assertThat(downloaded.contentType()).isEqualTo("application/pdf");
        assertThat(downloaded.size()).isEqualTo(4096L);
        assertThat(downloaded.resource()).isSameAs(resource);
    }

    @Test
    @DisplayName("Deve lançar NotFoundException ao tentar download de anexo inexistente")
    void shouldThrowNotFoundExceptionWhenDownloadingNonExistentAttachment() {
        when(attachmentRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> attachmentService.download(999L))
                .isInstanceOf(NotFoundException.class);
    }

    @Test
    @DisplayName("Deve rejeitar upload de anexo quando obrigação estiver concluída (COMPLETED) com 422")
    void shouldRejectUploadWhenObligationIsCompleted() {
        Obligation completedObligation = new Obligation();
        completedObligation.setId(5L);
        completedObligation.changeStatus(ObligationStatus.IN_PROGRESS, clock);
        completedObligation.changeStatus(ObligationStatus.COMPLETED, clock);

        when(obligationRepository.findById(5L)).thenReturn(Optional.of(completedObligation));

        MockMultipartFile file = new MockMultipartFile(
                "file", "guia.pdf", "application/pdf", "dados".getBytes()
        );

        assertThatThrownBy(() -> attachmentService.upload(5L, file))
                .isInstanceOf(BusinessRuleException.class)
                .hasMessage("Não é permitido adicionar novos anexos a uma obrigação já concluída.")
                .satisfies(ex -> assertThat(((BusinessRuleException) ex).getCode()).isEqualTo("OBLIGATION_COMPLETED"));

        verifyNoInteractions(fileStorage);
    }
}

