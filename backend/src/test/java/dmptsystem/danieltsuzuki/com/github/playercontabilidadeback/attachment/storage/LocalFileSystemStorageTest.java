package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.storage;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.core.io.Resource;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class LocalFileSystemStorageTest {

    @TempDir
    Path tempDir;

    private LocalFileSystemStorage storage;

    @BeforeEach
    void setUp() {
        storage = new LocalFileSystemStorage(tempDir.toString());
    }

    @Test
    @DisplayName("Deve salvar arquivo no disco gerando caminho seguro com extensão correta")
    void shouldStoreFileSuccessfully() throws IOException {
        String content = "Conteúdo binário simulado de guia DARF";
        ByteArrayInputStream is = new ByteArrayInputStream(content.getBytes(StandardCharsets.UTF_8));

        String storageKey = storage.store(is, 15L, "guia_darf.PDF");

        assertThat(storageKey).startsWith("15/").endsWith(".pdf");

        Path storedFile = tempDir.resolve(storageKey);
        assertThat(Files.exists(storedFile)).isTrue();
        assertThat(Files.readString(storedFile)).isEqualTo(content);
    }

    @Test
    @DisplayName("Deve carregar recurso existente com sucesso")
    void shouldLoadExistingFileSuccessfully() throws IOException {
        ByteArrayInputStream is = new ByteArrayInputStream("Comprovante DCTF".getBytes(StandardCharsets.UTF_8));
        String storageKey = storage.store(is, 20L, "comprovante.xml");

        Resource resource = storage.load(storageKey);

        assertThat(resource).isNotNull();
        assertThat(resource.exists()).isTrue();
        assertThat(resource.isReadable()).isTrue();
        assertThat(resource.getContentAsString(StandardCharsets.UTF_8)).isEqualTo("Comprovante DCTF");
    }

    @Test
    @DisplayName("Deve lançar NotFoundException ao tentar carregar arquivo inexistente no disco")
    void shouldThrowNotFoundExceptionWhenFileDoesNotExistOnDisk() {
        assertThatThrownBy(() -> storage.load("20/arquivo-inexistente.pdf"))
                .isInstanceOf(NotFoundException.class)
                .hasMessageContaining("Arquivo físico");
    }

    @Test
    @DisplayName("Deve bloquear tentativa de path traversal no load")
    void shouldBlockPathTraversalOnLoad() {
        assertThatThrownBy(() -> storage.load("../../windows/system32/cmd.exe"))
                .isInstanceOf(StorageException.class)
                .hasMessageContaining("Tentativa de acesso fora do diretório base permitido.");
    }

    @Test
    @DisplayName("Deve excluir arquivo físico do disco com sucesso")
    void shouldDeleteFileSuccessfully() {
        ByteArrayInputStream is = new ByteArrayInputStream("dados temporarios".getBytes(StandardCharsets.UTF_8));
        String storageKey = storage.store(is, 10L, "recibo.txt");
        Path file = tempDir.resolve(storageKey);
        assertThat(Files.exists(file)).isTrue();

        storage.delete(storageKey);

        assertThat(Files.exists(file)).isFalse();
    }
}

