package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.security;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import jakarta.persistence.EntityManager;
import org.springframework.data.domain.AuditorAware;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Optional;

@Component
public class SecurityAuditorAware implements AuditorAware<Responsible> {

    private final EntityManager entityManager;

    public SecurityAuditorAware(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    @Override
    public Optional<Responsible> getCurrentAuditor() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null || !authentication.isAuthenticated() || authentication instanceof AnonymousAuthenticationToken) {
            return Optional.empty();
        }

        Object principal = authentication.getPrincipal();
        if (principal instanceof UserPrincipal userPrincipal && userPrincipal.getId() != null) {
            return Optional.of(entityManager.getReference(Responsible.class, userPrincipal.getId()));
        }

        return Optional.empty();
    }
}
