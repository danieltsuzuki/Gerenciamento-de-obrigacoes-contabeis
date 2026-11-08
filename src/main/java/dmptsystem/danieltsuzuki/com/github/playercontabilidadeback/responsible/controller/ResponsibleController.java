package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.controller;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.CreateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.UpdateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.service.ResponsibleService;
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
public class ResponsibleController {

    private final ResponsibleService responsibleService;

    public ResponsibleController(ResponsibleService responsibleService) {
        this.responsibleService = responsibleService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ResponsibleResponse create(@Valid @RequestBody CreateResponsibleRequest request) {
        return responsibleService.create(request);
    }

    @GetMapping
    public Page<ResponsibleResponse> list(
            @RequestParam(required = false) Boolean active,
            Pageable pageable
    ) {
        return responsibleService.findAll(active, pageable);
    }

    @GetMapping("/{id}")
    public ResponsibleResponse getById(@PathVariable Long id) {
        return responsibleService.findById(id);
    }

    @PutMapping("/{id}")
    public ResponsibleResponse update(
            @PathVariable Long id,
            @Valid @RequestBody UpdateResponsibleRequest request
    ) {
        return responsibleService.update(id, request);
    }
}

