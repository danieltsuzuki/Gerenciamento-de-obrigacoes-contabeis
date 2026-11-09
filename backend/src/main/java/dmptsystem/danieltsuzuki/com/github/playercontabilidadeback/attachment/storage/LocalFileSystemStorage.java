package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.storage;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Component
public class LocalFileSystemStorage implements FileStorage {

    private final Path rootLocation;

    public LocalFileSystemStorage(@Value("${storage.location:uploads}") String location) {
        this.rootLocation = Paths.get(location).toAbsolutePath().normalize();
    }

    @Override
    public String store(InputStream inputStream, Long obligationId, String originalFilename) {
        if (obligationId == null) {
            throw new StorageException("Identificador da obrigação não pode ser nulo.");
        }
        if (inputStream == null) {
            throw new StorageException("Fluxo de dados do arquivo não pode ser nulo.");
        }

        String extension = extractSafeExtension(originalFilename);
        String safeName = UUID.randomUUID() + extension;
        String storageKey = obligationId + "/" + safeName;

        Path targetDir = rootLocation.resolve(String.valueOf(obligationId)).normalize();
        Path targetFile = rootLocation.resolve(storageKey).normalize();

        if (!targetFile.startsWith(rootLocation)) {
            throw new StorageException("Tentativa de gravação fora do diretório base permitido.");
        }

        try {
            Files.createDirectories(targetDir);
            Files.copy(inputStream, targetFile, StandardCopyOption.REPLACE_EXISTING);
            return storageKey;
        } catch (IOException e) {
            throw new StorageException("Falha ao salvar o arquivo no disco.", e);
        }
    }

    @Override
    public Resource load(String storageKey) {
        if (storageKey == null || storageKey.isBlank()) {
            throw new StorageException("Chave de armazenamento inválida.");
        }

        Path file = rootLocation.resolve(storageKey).normalize();

        if (!file.startsWith(rootLocation)) {
            throw new StorageException("Tentativa de acesso fora do diretório base permitido.");
        }

        try {
            Resource resource = new UrlResource(file.toUri());
            if (resource.exists() && resource.isReadable()) {
                return resource;
            }
            throw new NotFoundException("Arquivo físico", storageKey);
        } catch (MalformedURLException e) {
            throw new StorageException("Erro ao construir URI para o arquivo.", e);
        }
    }

    @Override
    public void delete(String storageKey) {
        if (storageKey == null || storageKey.isBlank()) {
            return;
        }

        Path file = rootLocation.resolve(storageKey).normalize();
        if (file.startsWith(rootLocation)) {
            try {
                Files.deleteIfExists(file);
            } catch (IOException e) {
                // Log and suppress on compensation failure
            }
        }
    }

    private String extractSafeExtension(String originalFilename) {
        if (originalFilename == null) {
            return "";
        }
        int lastDot = originalFilename.lastIndexOf('.');
        if (lastDot >= 0 && lastDot < originalFilename.length() - 1) {
            String rawExt = originalFilename.substring(lastDot);
            if (rawExt.matches("^\\.[a-zA-Z0-9]{1,10}$")) {
                return rawExt.toLowerCase();
            }
        }
        return "";
    }
}
