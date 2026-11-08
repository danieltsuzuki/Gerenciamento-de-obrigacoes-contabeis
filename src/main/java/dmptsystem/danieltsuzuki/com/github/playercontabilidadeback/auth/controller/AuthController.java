package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.service.AuthService;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.CreateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.service.ResponsibleService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;
    private final ResponsibleService responsibleService;

    public AuthController(AuthService authService, ResponsibleService responsibleService) {
        this.authService = authService;
        this.responsibleService = responsibleService;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public ResponsibleResponse register(@Valid @RequestBody CreateResponsibleRequest request) {
        return responsibleService.create(request);
    }
}
