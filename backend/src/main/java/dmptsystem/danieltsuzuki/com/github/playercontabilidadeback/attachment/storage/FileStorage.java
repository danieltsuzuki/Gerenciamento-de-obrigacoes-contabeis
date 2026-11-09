package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.storage;

import org.springframework.core.io.Resource;

import java.io.InputStream;

public interface FileStorage {

    String store(InputStream inputStream, Long obligationId, String originalFilename);

    Resource load(String storageKey);

    void delete(String storageKey);
}

