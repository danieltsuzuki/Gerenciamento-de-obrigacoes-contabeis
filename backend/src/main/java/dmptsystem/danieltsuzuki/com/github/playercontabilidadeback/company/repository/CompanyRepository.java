package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.repository;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.Repository;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface CompanyRepository extends Repository<Company, Long> {

    Company save(Company company);

    Optional<Company> findById(Long id);

    Page<Company> findAll(Pageable pageable);

    boolean existsByCnpj(String cnpj);

    boolean existsByCnpjAndIdNot(String cnpj, Long id);

    Optional<Company> findByCnpj(String cnpj);

    Page<Company> findByActive(boolean active, Pageable pageable);

    @Query(
            value = """
                    SELECT c FROM Company c
                    WHERE (:active IS NULL OR c.active = :active)
                      AND (
                        :q IS NULL OR :q = ''
                        OR LOWER(c.legalName) LIKE LOWER(CONCAT('%', :q, '%'))
                        OR (c.tradeName IS NOT NULL AND LOWER(c.tradeName) LIKE LOWER(CONCAT('%', :q, '%')))
                        OR (:cleanCnpj IS NOT NULL AND :cleanCnpj <> '' AND c.cnpj LIKE CONCAT('%', :cleanCnpj, '%'))
                      )
                    """,
            countQuery = """
                    SELECT COUNT(c) FROM Company c
                    WHERE (:active IS NULL OR c.active = :active)
                      AND (
                        :q IS NULL OR :q = ''
                        OR LOWER(c.legalName) LIKE LOWER(CONCAT('%', :q, '%'))
                        OR (c.tradeName IS NOT NULL AND LOWER(c.tradeName) LIKE LOWER(CONCAT('%', :q, '%')))
                        OR (:cleanCnpj IS NOT NULL AND :cleanCnpj <> '' AND c.cnpj LIKE CONCAT('%', :cleanCnpj, '%'))
                      )
                    """
    )
    Page<Company> search(
            @Param("active") Boolean active,
            @Param("q") String q,
            @Param("cleanCnpj") String cleanCnpj,
            Pageable pageable
    );
}
