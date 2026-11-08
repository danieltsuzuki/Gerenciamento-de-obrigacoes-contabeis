package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.Obligation;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Optional;

public interface ObligationRepository extends Repository<Obligation, Long> {

    Obligation save(Obligation obligation);

    @EntityGraph(attributePaths = {"company", "responsible"})
    Optional<Obligation> findById(Long id);

    @EntityGraph(attributePaths = {"company", "responsible"})
    Page<Obligation> findAll(Pageable pageable);

    @Query(
            value = """
                    select o from Obligation o
                    join fetch o.company
                    join fetch o.responsible
                    where (:companyId is null or o.company.id = :companyId)
                      and (:responsibleId is null or o.responsible.id = :responsibleId)
                      and (:status is null or o.status = :status)
                      and (:dueFrom is null or o.dueDate >= :dueFrom)
                      and (:dueTo is null or o.dueDate <= :dueTo)
                    """,
            countQuery = """
                    select count(o) from Obligation o
                    where (:companyId is null or o.company.id = :companyId)
                      and (:responsibleId is null or o.responsible.id = :responsibleId)
                      and (:status is null or o.status = :status)
                      and (:dueFrom is null or o.dueDate >= :dueFrom)
                      and (:dueTo is null or o.dueDate <= :dueTo)
                    """
    )
    Page<Obligation> findByFilters(
            @Param("companyId") Long companyId,
            @Param("responsibleId") Long responsibleId,
            @Param("status") ObligationStatus status,
            @Param("dueFrom") LocalDate dueFrom,
            @Param("dueTo") LocalDate dueTo,
            Pageable pageable
    );
}
