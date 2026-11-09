package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.CreateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationDetailResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationListItemResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.UpdateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.UpdateObligationStatusRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.service.ObligationService;
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
public class ObligationController {

    private final ObligationService obligationService;

    public ObligationController(ObligationService obligationService) {
        this.obligationService = obligationService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ObligationDetailResponse create(@Valid @RequestBody CreateObligationRequest request) {
        return obligationService.create(request);
    }

    @GetMapping
    public Page<ObligationListItemResponse> list(
            @RequestParam(required = false) Long companyId,
            @RequestParam(required = false) Long responsibleId,
            @RequestParam(required = false) ObligationStatus status,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dueFrom,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate dueTo,
            Pageable pageable
    ) {
        return obligationService.findAll(companyId, responsibleId, status, dueFrom, dueTo, pageable);
    }

    @GetMapping("/{id}")
    public ObligationDetailResponse getById(@PathVariable Long id) {
        return obligationService.findById(id);
    }

    @PutMapping("/{id}")
    public ObligationDetailResponse update(
            @PathVariable Long id,
            @Valid @RequestBody UpdateObligationRequest request
    ) {
        return obligationService.update(id, request);
    }

    @PatchMapping("/{id}/status")
    public ObligationDetailResponse updateStatus(
            @PathVariable Long id,
            @Valid @RequestBody UpdateObligationStatusRequest request
    ) {
        return obligationService.updateStatus(id, request.status());
    }
}
