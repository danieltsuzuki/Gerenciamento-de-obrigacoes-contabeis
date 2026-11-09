package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.CreateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationDetailResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationListItemResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.UpdateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.UpdateObligationStatusRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.service.ObligationService;
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
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/obligations")
@Tag(name = "Obrigações", description = "Operações para ciclo de vida, filtros e máquina de estados das obrigações fiscais")
public class ObligationController {

    private final ObligationService obligationService;

    public ObligationController(ObligationService obligationService) {
        this.obligationService = obligationService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Cria obrigação fiscal", description = "Cria uma nova obrigação fiscal vinculada a uma empresa ativa e a um responsável ativo. Toda obrigação nasce no estado PENDING. Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Obrigação criada com sucesso com status PENDING"),
            @ApiResponse(responseCode = "400", description = "Dados da requisição inválidos"),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "404", description = "Empresa ou responsável não encontrados"),
            @ApiResponse(responseCode = "422", description = "Empresa ou responsável informados estão inativos")
    })
    public ObligationDetailResponse create(@Valid @RequestBody CreateObligationRequest request) {
        return obligationService.create(request);
    }

    @GetMapping
    @SecurityRequirements
    @Operation(summary = "Lista obrigações fiscais", description = "Retorna lista paginada de obrigações com filtros combináveis por empresa, responsável, status e intervalo de vencimento.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Listagem retornada com sucesso")
    })
    public Page<ObligationListItemResponse> list(
            @Parameter(description = "Filtrar por ID da empresa cliente", example = "1")
            @RequestParam(required = false) Long companyId,

            @Parameter(description = "Filtrar por ID do responsável contábil", example = "1")
            @RequestParam(required = false) Long responsibleId,

            @Parameter(description = "Filtrar por status (PENDING, IN_PROGRESS, COMPLETED)", example = "PENDING")
            @RequestParam(required = false) ObligationStatus status,

            @Parameter(description = "Data de vencimento inicial (inclusive) - YYYY-MM-DD", example = "2026-11-01")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dueFrom,

            @Parameter(description = "Data de vencimento final (inclusive) - YYYY-MM-DD", example = "2026-11-30")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dueTo,

            @Parameter(hidden = true) Pageable pageable
    ) {
        return obligationService.findAll(companyId, responsibleId, status, dueFrom, dueTo, pageable);
    }

    @GetMapping("/{id}")
    @SecurityRequirements
    @Operation(summary = "Busca detalhes de uma obrigação por ID", description = "Recupera dados completos da obrigação, incluindo dados resumidos da empresa e do responsável, contagem de anexos e datas.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Obrigação encontrada com sucesso"),
            @ApiResponse(responseCode = "404", description = "Obrigação não encontrada")
    })
    public ObligationDetailResponse getById(
            @Parameter(description = "Identificador único da obrigação", example = "1")
            @PathVariable Long id
    ) {
        return obligationService.findById(id);
    }

    @PutMapping("/{id}")
    @Operation(summary = "Atualiza dados cadastrais da obrigação", description = "Atualiza título, descrição, prazo, empresa e responsável da obrigação. Se os vínculos forem alterados, valida se novos participantes estão ativos. Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Obrigação atualizada com sucesso"),
            @ApiResponse(responseCode = "400", description = "Dados da requisição inválidos"),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "404", description = "Obrigação, empresa ou responsável não encontrados"),
            @ApiResponse(responseCode = "422", description = "Novo participante informado está inativo ou transição inválida")
    })
    public ObligationDetailResponse update(
            @Parameter(description = "Identificador único da obrigação", example = "1")
            @PathVariable Long id,
            @Valid @RequestBody UpdateObligationRequest request
    ) {
        return obligationService.update(id, request);
    }

    @PatchMapping("/{id}/status")
    @Operation(summary = "Atualiza o status na máquina de estados", description = "Executa transição de status da obrigação fiscal. Regras estritas: PENDING -> IN_PROGRESS -> COMPLETED. Regressões e saltos são bloqueados. COMPLETED é terminal e não pode ser reaberta. Preenche completed_at ao concluir. Requer autenticação JWT.",
            security = @SecurityRequirement(name = "bearerAuth"))
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Status alterado com sucesso"),
            @ApiResponse(responseCode = "400", description = "Status inválido ou não informado"),
            @ApiResponse(responseCode = "401", description = "Não autenticado"),
            @ApiResponse(responseCode = "404", description = "Obrigação não encontrada"),
            @ApiResponse(responseCode = "422", description = "Transição ilegal (salto, regressão ou reabertura de concluída)")
    })
    public ObligationDetailResponse updateStatus(
            @Parameter(description = "Identificador único da obrigação", example = "1")
            @PathVariable Long id,
            @Valid @RequestBody UpdateObligationStatusRequest request
    ) {
        return obligationService.updateStatus(id, request.status());
    }
}
