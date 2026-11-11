package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanyResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CreateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.UpdateCompanyRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.service.CompanyService;
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
@RequestMapping("/api/companies")
@Tag(name = "Empresas", description = "Operações para cadastro, listagem, atualização e inativação de empresas clientes")
public class CompanyController {

    private final CompanyService companyService;

    public CompanyController(CompanyService companyService) {
        this.companyService = companyService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Cadastra nova empresa", description = "Cria uma nova empresa cliente no sistema. Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Empresa cadastrada com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados da empresa inválidos ou CNPJ com formato/DVs incorretos"),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "422", description = "CNPJ já existente no sistema")
    })
    public CompanyResponse create(@Valid @RequestBody CreateCompanyRequest request) {
        return companyService.create(request);
    }

    @GetMapping
    @SecurityRequirements
    @Operation(summary = "Lista empresas cadastradas", description = "Retorna lista paginada de empresas. Permite filtro por status ativo/inativo e busca textual por razão social, nome fantasia ou CNPJ.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Listagem de empresas retornada com sucesso"),
            @ApiResponse(responseCode = "400", description = "Parâmetro de busca inválido ou excede 100 caracteres")
    })
    public Page<CompanyResponse> list(
            @Parameter(description = "Filtro opcional por situação da empresa (true para ativas, false para inativas)")
            @RequestParam(required = false) Boolean active,
            @Parameter(description = "Termo de busca textual opcional (razão social, nome fantasia ou CNPJ)")
            @RequestParam(required = false) String q,
            @Parameter(hidden = true) Pageable pageable
    ) {
        if (q != null && !q.trim().isEmpty()) {
            return companyService.findAll(active, q, pageable);
        }
        return companyService.findAll(active, pageable);
    }

    @GetMapping("/{id}")
    @SecurityRequirements
    @Operation(summary = "Busca empresa por ID", description = "Recupera os detalhes de uma empresa cliente pelo seu identificador único.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Empresa encontrada"),
            @ApiResponse(responseCode = "404", description = "Empresa não encontrada")
    })
    public CompanyResponse getById(
            @Parameter(description = "Identificador único da empresa", example = "1")
            @PathVariable Long id
    ) {
        return companyService.findById(id);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Atualiza dados da empresa", description = "Atualiza os dados cadastrais da empresa ou altera a sua situação ativa/inativa (soft delete). Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Empresa atualizada com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados de atualização inválidos"),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "404", description = "Empresa não encontrada"),
            @ApiResponse(responseCode = "422", description = "Novo CNPJ já cadastrado para outra empresa")
    })
    public CompanyResponse update(
            @Parameter(description = "Identificador único da empresa", example = "1")
            @PathVariable Long id,
            @Valid @RequestBody UpdateCompanyRequest request
    ) {
        return companyService.update(id, request);
    }
}
