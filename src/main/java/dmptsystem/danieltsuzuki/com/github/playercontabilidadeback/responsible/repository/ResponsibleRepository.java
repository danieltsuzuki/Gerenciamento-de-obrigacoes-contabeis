package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.Repository;

import java.util.Optional;

public interface ResponsibleRepository extends Repository<Responsible, Long> {

    Responsible save(Responsible responsible);

    Optional<Responsible> findById(Long id);

    Page<Responsible> findAll(Pageable pageable);

    boolean existsByEmail(String email);

    Optional<Responsible> findByEmail(String email);

    Page<Responsible> findByActive(boolean active, Pageable pageable);
}
