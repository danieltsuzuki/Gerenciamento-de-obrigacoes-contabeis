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
                      and (
                        :q is null or :q = ''
                        or lower(o.title) like lower(concat('%', :q, '%'))
                        or (o.description is not null and lower(o.description) like lower(concat('%', :q, '%')))
                        or lower(o.company.legalName) like lower(concat('%', :q, '%'))
                        or (o.company.tradeName is not null and lower(o.company.tradeName) like lower(concat('%', :q, '%')))
                        or lower(o.responsible.name) like lower(concat('%', :q, '%'))
                      )
                    """,
            countQuery = """
                    select count(o) from Obligation o
                    where (:companyId is null or o.company.id = :companyId)
                      and (:responsibleId is null or o.responsible.id = :responsibleId)
                      and (:status is null or o.status = :status)
                      and (:dueFrom is null or o.dueDate >= :dueFrom)
                      and (:dueTo is null or o.dueDate <= :dueTo)
                      and (
                        :q is null or :q = ''
                        or lower(o.title) like lower(concat('%', :q, '%'))
                        or (o.description is not null and lower(o.description) like lower(concat('%', :q, '%')))
                        or lower(o.company.legalName) like lower(concat('%', :q, '%'))
                        or (o.company.tradeName is not null and lower(o.company.tradeName) like lower(concat('%', :q, '%')))
                        or lower(o.responsible.name) like lower(concat('%', :q, '%'))
                      )
                    """
    )
    Page<Obligation> findByFilters(
            @Param("companyId") Long companyId,
            @Param("responsibleId") Long responsibleId,
            @Param("status") ObligationStatus status,
            @Param("dueFrom") LocalDate dueFrom,
            @Param("dueTo") LocalDate dueTo,
            @Param("q") String q,
            Pageable pageable
    );

    default Page<Obligation> findByFilters(
            Long companyId,
            Long responsibleId,
            ObligationStatus status,
            LocalDate dueFrom,
            LocalDate dueTo,
            Pageable pageable
    ) {
        return findByFilters(companyId, responsibleId, status, dueFrom, dueTo, null, pageable);
    }

    @Query(
            value = """
                    select new dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationWithAttachmentCount(
                        o,
                        (select count(a) from Attachment a where a.obligation = o)
                    )
                    from Obligation o
                    join fetch o.company
                    join fetch o.responsible
                    where (:companyId is null or o.company.id = :companyId)
                      and (:responsibleId is null or o.responsible.id = :responsibleId)
                      and (:status is null or o.status = :status)
                      and (:dueFrom is null or o.dueDate >= :dueFrom)
                      and (:dueTo is null or o.dueDate <= :dueTo)
                      and (
                        :q is null or :q = ''
                        or lower(o.title) like lower(concat('%', :q, '%'))
                        or (o.description is not null and lower(o.description) like lower(concat('%', :q, '%')))
                        or lower(o.company.legalName) like lower(concat('%', :q, '%'))
                        or (o.company.tradeName is not null and lower(o.company.tradeName) like lower(concat('%', :q, '%')))
                        or lower(o.responsible.name) like lower(concat('%', :q, '%'))
                      )
                    """,
            countQuery = """
                    select count(o) from Obligation o
                    where (:companyId is null or o.company.id = :companyId)
                      and (:responsibleId is null or o.responsible.id = :responsibleId)
                      and (:status is null or o.status = :status)
                      and (:dueFrom is null or o.dueDate >= :dueFrom)
                      and (:dueTo is null or o.dueDate <= :dueTo)
                      and (
                        :q is null or :q = ''
                        or lower(o.title) like lower(concat('%', :q, '%'))
                        or (o.description is not null and lower(o.description) like lower(concat('%', :q, '%')))
                        or lower(o.company.legalName) like lower(concat('%', :q, '%'))
                        or (o.company.tradeName is not null and lower(o.company.tradeName) like lower(concat('%', :q, '%')))
                        or lower(o.responsible.name) like lower(concat('%', :q, '%'))
                      )
                    """
    )
    Page<dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationWithAttachmentCount> findWithAttachmentCountByFilters(
            @Param("companyId") Long companyId,
            @Param("responsibleId") Long responsibleId,
            @Param("status") ObligationStatus status,
            @Param("dueFrom") LocalDate dueFrom,
            @Param("dueTo") LocalDate dueTo,
            @Param("q") String q,
            Pageable pageable
    );

    default Page<dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationWithAttachmentCount> findWithAttachmentCountByFilters(
            Long companyId,
            Long responsibleId,
            ObligationStatus status,
            LocalDate dueFrom,
            LocalDate dueTo,
            Pageable pageable
    ) {
        return findWithAttachmentCountByFilters(companyId, responsibleId, status, dueFrom, dueTo, null, pageable);
    }
}
