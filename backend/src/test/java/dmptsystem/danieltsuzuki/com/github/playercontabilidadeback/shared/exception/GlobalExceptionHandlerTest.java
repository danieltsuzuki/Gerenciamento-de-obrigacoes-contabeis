package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.exception.InvalidFileException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.storage.StorageException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.exception.InvalidStatusTransitionException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

class GlobalExceptionHandlerTest {

    private GlobalExceptionHandler exceptionHandler;

    @BeforeEach
    void setUp() {
        exceptionHandler = new GlobalExceptionHandler();
    }

    @Test
    @DisplayName("Deve tratar MethodArgumentNotValidException retornando 400 e lista de detalhes")
    void shouldHandleMethodArgumentNotValidException() {
        MethodArgumentNotValidException ex = mock(MethodArgumentNotValidException.class);
        BindingResult bindingResult = mock(BindingResult.class);
        FieldError fieldError = new FieldError("objectName", "fieldName", "must not be blank");
        when(bindingResult.getFieldErrors()).thenReturn(List.of(fieldError));
        when(ex.getBindingResult()).thenReturn(bindingResult);

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleValidationException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("VALIDATION_ERROR");
        assertThat(response.getBody().details()).containsExactly("fieldName: must not be blank");
        assertThat(response.getBody().timestamp()).isNotNull();
    }

    @Test
    @DisplayName("Deve tratar NotFoundException retornando 404")
    void shouldHandleNotFoundException() {
        NotFoundException ex = new NotFoundException("Empresa", 1L);

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleNotFoundException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("NOT_FOUND");
        assertThat(response.getBody().message()).contains("Empresa não encontrada(o) com identificador: 1");
    }

    @Test
    @DisplayName("Deve tratar DuplicateResourceException retornando 409")
    void shouldHandleDuplicateResourceException() {
        DuplicateResourceException ex = new DuplicateResourceException("DUPLICATE_CNPJ", "CNPJ duplicado");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleDuplicateResourceException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("DUPLICATE_CNPJ");
        assertThat(response.getBody().message()).isEqualTo("CNPJ duplicado");
    }

    @Test
    @DisplayName("Deve tratar DataIntegrityViolationException de CNPJ retornando 409 DUPLICATE_CNPJ")
    void shouldHandleDataIntegrityViolationCnpj() {
        DataIntegrityViolationException ex = new DataIntegrityViolationException("Duplicate entry for key uk_company_cnpj");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleDataIntegrityViolationException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("DUPLICATE_CNPJ");
    }

    @Test
    @DisplayName("Deve tratar DataIntegrityViolationException de e-mail retornando 409 DUPLICATE_EMAIL")
    void shouldHandleDataIntegrityViolationEmail() {
        DataIntegrityViolationException ex = new DataIntegrityViolationException("Duplicate entry for key uk_users_email");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleDataIntegrityViolationException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("DUPLICATE_EMAIL");
    }

    @Test
    @DisplayName("Deve tratar BadCredentialsException retornando 401")
    void shouldHandleBadCredentialsException() {
        BadCredentialsException ex = new BadCredentialsException("Credenciais inválidas");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleBadCredentialsException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("BAD_CREDENTIALS");
    }

    @Test
    @DisplayName("Deve tratar BusinessRuleException retornando 422")
    void shouldHandleBusinessRuleException() {
        BusinessRuleException ex = new BusinessRuleException("USER_INACTIVE", "Usuário inativo");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleBusinessRuleException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNPROCESSABLE_ENTITY);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("USER_INACTIVE");
    }

    @Test
    @DisplayName("Deve tratar InvalidStatusTransitionException retornando 422 INVALID_STATUS_TRANSITION")
    void shouldHandleInvalidStatusTransitionException() {
        InvalidStatusTransitionException ex = new InvalidStatusTransitionException(
                dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus.PENDING,
                dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus.COMPLETED
        );

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleInvalidStatusTransitionException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNPROCESSABLE_ENTITY);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("INVALID_STATUS_TRANSITION");
    }

    @Test
    @DisplayName("Deve tratar InvalidFileException retornando 400 VALIDATION_ERROR")
    void shouldHandleInvalidFileException() {
        InvalidFileException ex = new InvalidFileException("Arquivo inválido");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleInvalidFileException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("VALIDATION_ERROR");
    }

    @Test
    @DisplayName("Deve tratar MaxUploadSizeExceededException retornando 400 VALIDATION_ERROR")
    void shouldHandleMaxUploadSizeExceededException() {
        MaxUploadSizeExceededException ex = new MaxUploadSizeExceededException(10 * 1024 * 1024);

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleMaxUploadSizeExceededException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("VALIDATION_ERROR");
    }

    @Test
    @DisplayName("Deve tratar StorageException retornando 500 STORAGE_ERROR")
    void shouldHandleStorageException() {
        StorageException ex = new StorageException("Erro de disco");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleStorageException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("STORAGE_ERROR");
    }

    @Test
    @DisplayName("Deve tratar IllegalArgumentException retornando 400 BAD_REQUEST")
    void shouldHandleIllegalArgumentException() {
        IllegalArgumentException ex = new IllegalArgumentException("Parâmetro inválido");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleIllegalArgumentException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("BAD_REQUEST");
    }

    @Test
    @DisplayName("Deve tratar HttpRequestMethodNotSupportedException retornando 405 METHOD_NOT_ALLOWED")
    void shouldHandleHttpRequestMethodNotSupportedException() {
        org.springframework.web.HttpRequestMethodNotSupportedException ex =
                new org.springframework.web.HttpRequestMethodNotSupportedException("DELETE");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleHttpRequestMethodNotSupportedException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.METHOD_NOT_ALLOWED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("METHOD_NOT_ALLOWED");
    }

    @Test
    @DisplayName("Deve tratar exceção genérica retornando 500 INTERNAL_SERVER_ERROR sem expor stack trace")
    void shouldHandleGenericException() {
        RuntimeException ex = new RuntimeException("Erro inesperado");

        ResponseEntity<ErrorResponse> response = exceptionHandler.handleGenericException(ex);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.INTERNAL_SERVER_ERROR);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().code()).isEqualTo("INTERNAL_SERVER_ERROR");
        assertThat(response.getBody().message()).isEqualTo("Ocorreu um erro interno no servidor.");
        assertThat(response.getBody().details()).isEmpty();
    }
}
