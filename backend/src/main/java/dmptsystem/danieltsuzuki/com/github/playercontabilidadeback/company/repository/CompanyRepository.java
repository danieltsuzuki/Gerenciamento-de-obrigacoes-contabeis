package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.repository;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.Repository;

import java.util.Optional;

public interface CompanyRepository extends Repository<Company, Long> {

    Company save(Company company);

    Optional<Company> findById(Long id);

    Page<Company> findAll(Pageable pageable);

    boolean existsByCnpj(String cnpj);

    boolean existsByCnpjAndIdNot(String cnpj, Long id);

    Optional<Company> findByCnpj(String cnpj);

    Page<Company> findByActive(boolean active, Pageable pageable);
}
