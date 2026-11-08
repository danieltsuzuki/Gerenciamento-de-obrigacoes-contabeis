package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.mapper;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.CreateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.UpdateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import org.springframework.stereotype.Component;

@Component
public class ResponsibleMapper {

    public Responsible toEntity(CreateResponsibleRequest request) {
        if (request == null) {
            return null;
        }
        Responsible responsible = new Responsible();
        responsible.setName(request.name());
        responsible.setEmail(request.email());
        if (request.active() != null) {
            responsible.setActive(request.active());
        }
        return responsible;
    }

    public void updateEntity(UpdateResponsibleRequest request, Responsible responsible) {
        if (request == null || responsible == null) {
            return;
        }
        responsible.setName(request.name());
        responsible.setEmail(request.email());
        responsible.setActive(request.active());
    }

    public ResponsibleResponse toResponse(Responsible responsible) {
        if (responsible == null) {
            return null;
        }
        return new ResponsibleResponse(
                responsible.getId(),
                responsible.getName(),
                responsible.getEmail(),
                responsible.isActive(),
                responsible.getCreatedAt(),
                responsible.getUpdatedAt()
        );
    }
}

