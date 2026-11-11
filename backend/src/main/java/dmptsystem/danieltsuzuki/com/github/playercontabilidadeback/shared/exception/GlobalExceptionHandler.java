package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.ArrayList;
import java.util.List;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(MethodArgumentNotValidException ex) {
        List<String> details = new ArrayList<>();
        for (FieldError fieldError : ex.getBindingResult().getFieldErrors()) {
            details.add(fieldError.getField() + ": " + fieldError.getDefaultMessage());
        }
        ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", "Dados da requisição inválidos", details);
        log.warn("Validation error (400): {}", details);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFoundException(NotFoundException ex) {
        ErrorResponse error = new ErrorResponse("NOT_FOUND", ex.getMessage());
        log.warn("Resource not found (404): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    @ExceptionHandler(DuplicateResourceException.class)
    public ResponseEntity<ErrorResponse> handleDuplicateResourceException(DuplicateResourceException ex) {
        ErrorResponse error = new ErrorResponse(ex.getCode(), ex.getMessage());
        log.warn("Duplicate resource conflict (409): code={}, message={}", ex.getCode(), ex.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
    }

    @ExceptionHandler(DataIntegrityViolationException.class)
    public ResponseEntity<ErrorResponse> handleDataIntegrityViolationException(DataIntegrityViolationException ex) {
        String msg = ex.getMessage() != null ? ex.getMessage().toLowerCase() : "";
        if (msg.contains("cnpj") || msg.contains("uk_company_cnpj")) {
            ErrorResponse error = new ErrorResponse("DUPLICATE_CNPJ", "CNPJ já cadastrado para outra empresa.");
            log.warn("Data integrity conflict - duplicate CNPJ (409)");
            return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
        }
        if (msg.contains("email") || msg.contains("uk_users_email")) {
            ErrorResponse error = new ErrorResponse("DUPLICATE_EMAIL", "E-mail já cadastrado para outro usuário.");
            log.warn("Data integrity conflict - duplicate email (409)");
            return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
        }
        ErrorResponse error = new ErrorResponse("DATA_INTEGRITY_VIOLATION", "Violação de integridade de dados.");
        log.warn("Data integrity violation (409): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
    }

    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ErrorResponse> handleBadCredentialsException(BadCredentialsException ex) {
        ErrorResponse error = new ErrorResponse("BAD_CREDENTIALS", ex.getMessage());
        log.warn("Bad credentials (401): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
    }

    @ExceptionHandler(org.springframework.security.access.AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDeniedException(org.springframework.security.access.AccessDeniedException ex) {
        ErrorResponse error = new ErrorResponse("FORBIDDEN", ex.getMessage());
        log.warn("Access denied (403): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
    }

    @ExceptionHandler(BusinessRuleException.class)
    public ResponseEntity<ErrorResponse> handleBusinessRuleException(BusinessRuleException ex) {
        ErrorResponse error = new ErrorResponse(ex.getCode(), ex.getMessage());
        log.warn("Business rule violation (422): code={}, message={}", ex.getCode(), ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(error);
    }

    @ExceptionHandler(dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.exception.InvalidStatusTransitionException.class)
    public ResponseEntity<ErrorResponse> handleInvalidStatusTransitionException(
            dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.exception.InvalidStatusTransitionException ex
    ) {
        ErrorResponse error = new ErrorResponse("INVALID_STATUS_TRANSITION", ex.getMessage());
        log.warn("Invalid obligation status transition (422): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(error);
    }

    @ExceptionHandler(dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.exception.InvalidFileException.class)
    public ResponseEntity<ErrorResponse> handleInvalidFileException(
            dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.exception.InvalidFileException ex
    ) {
        ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", ex.getMessage());
        log.warn("Invalid file upload (400): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(org.springframework.web.multipart.MaxUploadSizeExceededException.class)
    public ResponseEntity<ErrorResponse> handleMaxUploadSizeExceededException(
            org.springframework.web.multipart.MaxUploadSizeExceededException ex
    ) {
        ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", "Tamanho do arquivo excede o limite máximo permitido.");
        log.warn("Max upload size exceeded (400)");
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(SearchQueryTooLongException.class)
    public ResponseEntity<ErrorResponse> handleSearchQueryTooLongException(SearchQueryTooLongException ex) {
        ErrorResponse error = new ErrorResponse("VALIDATION_ERROR", ex.getMessage());
        log.warn("Search query too long (400): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.storage.StorageException.class)
    public ResponseEntity<ErrorResponse> handleStorageException(
            dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.storage.StorageException ex
    ) {
        ErrorResponse error = new ErrorResponse("STORAGE_ERROR", ex.getMessage());
        log.error("Storage error (500): {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ErrorResponse> handleIllegalArgumentException(IllegalArgumentException ex) {
        ErrorResponse error = new ErrorResponse("BAD_REQUEST", ex.getMessage());
        log.warn("Bad request (400): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    @ExceptionHandler(org.springframework.web.HttpRequestMethodNotSupportedException.class)
    public ResponseEntity<ErrorResponse> handleHttpRequestMethodNotSupportedException(
            org.springframework.web.HttpRequestMethodNotSupportedException ex
    ) {
        ErrorResponse error = new ErrorResponse("METHOD_NOT_ALLOWED", ex.getMessage());
        log.warn("Method not allowed (405): {}", ex.getMessage());
        return ResponseEntity.status(HttpStatus.METHOD_NOT_ALLOWED).body(error);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        ErrorResponse error = new ErrorResponse("INTERNAL_SERVER_ERROR", "Ocorreu um erro interno no servidor.");
        log.error("Internal server error (500): {}", ex.getMessage(), ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }
}

