package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.service.AuthService;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.CreateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.service.ResponsibleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
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
@Tag(name = "Autenticação", description = "Operações públicas para autenticação e registro de usuários")
public class AuthController {

    private final AuthService authService;
    private final ResponsibleService responsibleService;

    public AuthController(AuthService authService, ResponsibleService responsibleService) {
        this.authService = authService;
        this.responsibleService = responsibleService;
    }

    @PostMapping("/login")
    @SecurityRequirements
    @Operation(summary = "Realiza login de responsável", description = "Autentica o responsável por e-mail e senha e retorna token JWT.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Autenticação realizada com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados da requisição inválidos"),
            @ApiResponse(responseCode = "401", description = "Credenciais incorretas ou responsável inativo")
    })
    public ResponseEntity<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        LoginResponse response = authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    @SecurityRequirements
    @Operation(summary = "Registro público de responsável", description = "Permite o autocadastro do primeiro responsável ou novos usuários no sistema sem exigir token.")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Responsável cadastrado com sucesso"),
            @ApiResponse(responseCode = "400", description = "Campos obrigatórios ausentes ou inválidos"),
            @ApiResponse(responseCode = "422", description = "E-mail já utilizado por outro usuário")
    })
    public ResponsibleResponse register(@Valid @RequestBody CreateResponsibleRequest request) {
        return responsibleService.create(request);
    }
}
