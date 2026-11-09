package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception;

import java.time.LocalDateTime;
import java.util.List;

public record ErrorResponse(
        String code,
        String message,
        List<String> details,
        LocalDateTime timestamp
) {
    public ErrorResponse(String code, String message) {
        this(code, message, List.of(), LocalDateTime.now());
    }

    public ErrorResponse(String code, String message, List<String> details) {
        this(code, message, details, LocalDateTime.now());
    }
}

