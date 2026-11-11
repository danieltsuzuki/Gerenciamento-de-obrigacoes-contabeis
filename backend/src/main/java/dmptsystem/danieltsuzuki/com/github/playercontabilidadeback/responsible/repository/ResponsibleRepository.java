package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ResponsibleRepository extends Repository<Responsible, Long> {

    Responsible save(Responsible responsible);

    Optional<Responsible> findById(Long id);

    Page<Responsible> findAll(Pageable pageable);

    boolean existsByEmail(String email);

    boolean existsByEmailAndIdNot(String email, Long id);

    Optional<Responsible> findByEmail(String email);

    Page<Responsible> findByActive(boolean active, Pageable pageable);

    @Query(
            value = """
                    SELECT r FROM Responsible r
                    WHERE (:active IS NULL OR r.active = :active)
                      AND (
                        :q IS NULL OR :q = ''
                        OR LOWER(r.name) LIKE LOWER(CONCAT('%', :q, '%'))
                        OR LOWER(r.email) LIKE LOWER(CONCAT('%', :q, '%'))
                      )
                    """,
            countQuery = """
                    SELECT COUNT(r) FROM Responsible r
                    WHERE (:active IS NULL OR r.active = :active)
                      AND (
                        :q IS NULL OR :q = ''
                        OR LOWER(r.name) LIKE LOWER(CONCAT('%', :q, '%'))
                        OR LOWER(r.email) LIKE LOWER(CONCAT('%', :q, '%'))
                      )
                    """
    )
    Page<Responsible> search(
            @Param("active") Boolean active,
            @Param("q") String q,
            Pageable pageable
    );
}
