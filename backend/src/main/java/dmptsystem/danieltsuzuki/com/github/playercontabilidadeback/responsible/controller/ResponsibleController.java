package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.CreateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.UpdateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.service.ResponsibleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityRequirements;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/responsibles")
@Tag(name = "Responsáveis", description = "Operações para cadastro, listagem, atualização e inativação de responsáveis contábeis")
public class ResponsibleController {

    private final ResponsibleService responsibleService;

    public ResponsibleController(ResponsibleService responsibleService) {
        this.responsibleService = responsibleService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Cadastra novo responsável (interno)", description = "Cria um novo responsável no sistema. Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Responsável cadastrado com sucesso"),
            @ApiResponse(responseCode = "400", description = "Campos obrigatórios ausentes ou inválidos"),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "422", description = "E-mail já utilizado por outro usuário")
    })
    public ResponsibleResponse create(@Valid @RequestBody CreateResponsibleRequest request) {
        return responsibleService.create(request);
    }

    @GetMapping
    @SecurityRequirements
    @Operation(summary = "Lista responsáveis", description = "Retorna lista paginada de responsáveis cadastrados. Permite filtro por status ativo/inativo.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Listagem de responsáveis retornada com sucesso")
    })
    public Page<ResponsibleResponse> list(
            @Parameter(description = "Filtro opcional por situação do responsável (true para ativos, false para inativos)")
            @RequestParam(required = false) Boolean active,
            @Parameter(hidden = true) Pageable pageable
    ) {
        return responsibleService.findAll(active, pageable);
    }

    @GetMapping("/{id}")
    @SecurityRequirements
    @Operation(summary = "Busca responsável por ID", description = "Recupera os detalhes de um responsável pelo identificador único.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Responsável encontrado"),
            @ApiResponse(responseCode = "404", description = "Responsável não encontrado")
    })
    public ResponsibleResponse getById(
            @Parameter(description = "Identificador único do responsável", example = "1")
            @PathVariable Long id
    ) {
        return responsibleService.findById(id);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Atualiza dados do responsável", description = "Atualiza dados cadastrais ou inativa/reativa o responsável (soft delete). Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Responsável atualizado com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados da requisição inválidos"),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "404", description = "Responsável não encontrado"),
            @ApiResponse(responseCode = "422", description = "E-mail já utilizado por outro responsável")
    })
    public ResponsibleResponse update(
            @Parameter(description = "Identificador único do responsável", example = "1")
            @PathVariable Long id,
            @Valid @RequestBody UpdateResponsibleRequest request
    ) {
        return responsibleService.update(id, request);
    }
}
