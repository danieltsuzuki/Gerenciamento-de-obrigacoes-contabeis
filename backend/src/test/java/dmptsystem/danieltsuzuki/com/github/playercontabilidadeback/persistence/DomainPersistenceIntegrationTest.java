package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.persistence;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.entity.Attachment;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.repository.AttachmentRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.repository.CompanyRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.Obligation;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository.ObligationRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import jakarta.persistence.EntityManager;
import org.hibernate.Hibernate;
import org.hibernate.exception.ConstraintViolationException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.ImportAutoConfiguration;
import org.springframework.boot.data.jpa.test.autoconfigure.DataJpaTest;
import org.springframework.boot.flyway.autoconfigure.FlywayAutoConfiguration;
import org.springframework.boot.jdbc.test.autoconfigure.AutoConfigureTestDatabase;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.core.env.Environment;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.Clock;
import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

@DataJpaTest(properties = {
        "spring.jpa.hibernate.ddl-auto=validate",
        "spring.flyway.enabled=true"
})
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@ImportAutoConfiguration(FlywayAutoConfiguration.class)
@Testcontainers
class DomainPersistenceIntegrationTest {

    @Container
    @ServiceConnection
    static final MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0");

    @DynamicPropertySource
    static void datasource(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", mysql::getJdbcUrl);
        registry.add("spring.datasource.username", mysql::getUsername);
        registry.add("spring.datasource.password", mysql::getPassword);
    }

    @Autowired
    private Environment environment;

    @Autowired
    private EntityManager entityManager;

    @Autowired
    private CompanyRepository companyRepository;

    @Autowired
    private ResponsibleRepository responsibleRepository;

    @Autowired
    private ObligationRepository obligationRepository;

    @Autowired
    private AttachmentRepository attachmentRepository;

    @Test
    @DisplayName("1. contexto sobe com ddl-auto validate depois das migrations V1 e V2")
    void contextStartsWithValidatedSchema() {
        assertThat(environment.getProperty("spring.jpa.hibernate.ddl-auto")).isEqualTo("validate");

        Number migrations = (Number) entityManager.createNativeQuery(
                "SELECT COUNT(*) FROM flyway_schema_history WHERE success = 1 AND version IN ('1', '2')"
        ).getSingleResult();
        assertThat(migrations.intValue()).isEqualTo(2);

        Number legalName = (Number) entityManager.createNativeQuery(
                """
                SELECT COUNT(*) FROM information_schema.columns
                WHERE table_schema = DATABASE()
                  AND table_name = 'company'
                  AND column_name = 'legal_name'
                """
        ).getSingleResult();
        assertThat(legalName.intValue()).isEqualTo(1);
    }

    @Test
    @DisplayName("2. salvar e reler preenche createdAt e nasce com status PENDING")
    void saveAndReloadEachEntity() {
        Company company = company("Empresa Alfa", "11111111000191");
        company.setTradeName("Alfa");
        companyRepository.save(company);

        Responsible responsible = responsible("Ana Fiscal", "ana@empresa.com");
        responsibleRepository.save(responsible);

        Obligation obligation = obligation(company, responsible, "DCTF mensal", LocalDate.of(2026, 12, 15));
        obligationRepository.save(obligation);

        Attachment attachment = new Attachment();
        attachment.setName("comprovante.pdf");
        attachment.setContentType("application/pdf");
        attachment.setSize(2048L);
        attachment.setStorageKey("10/3f1c0a7e-comprovante.pdf");
        attachment.setObligation(obligation);
        attachmentRepository.save(attachment);

        entityManager.flush();
        entityManager.clear();

        Company reloadedCompany = companyRepository.findById(company.getId()).orElseThrow();
        Responsible reloadedResponsible = responsibleRepository.findById(responsible.getId()).orElseThrow();
        Obligation reloadedObligation = obligationRepository.findById(obligation.getId()).orElseThrow();
        Attachment reloadedAttachment = attachmentRepository.findById(attachment.getId()).orElseThrow();

        assertThat(reloadedCompany.getCreatedAt()).isNotNull();
        assertThat(reloadedCompany.getLegalName()).isEqualTo("Empresa Alfa");
        assertThat(reloadedCompany.getTradeName()).isEqualTo("Alfa");
        assertThat(reloadedCompany.isActive()).isTrue();
        assertThat(reloadedCompany.getUpdatedAt()).isNotNull();

        assertThat(reloadedResponsible.getCreatedAt()).isNotNull();
        assertThat(reloadedResponsible.isActive()).isTrue();
        assertThat(reloadedResponsible.getUpdatedAt()).isNotNull();
        assertThat(reloadedResponsible.toString()).doesNotContain("hash-nao-deve-aparecer");

        assertThat(reloadedObligation.getCreatedAt()).isNotNull();
        assertThat(reloadedObligation.getStatus()).isEqualTo(ObligationStatus.PENDING);
        assertThat(reloadedObligation.getCompletedAt()).isNull();
        assertThat(Hibernate.isInitialized(reloadedObligation.getCompany())).isTrue();
        assertThat(Hibernate.isInitialized(reloadedObligation.getResponsible())).isTrue();

        assertThat(reloadedAttachment.getUploadedAt()).isNotNull();
        assertThat(reloadedAttachment.getName()).isEqualTo("comprovante.pdf");
        assertThat(reloadedAttachment.getStorageKey()).isEqualTo("10/3f1c0a7e-comprovante.pdf");
        assertThat(attachmentRepository.findByObligationId(obligation.getId()))
                .extracting(Attachment::getName)
                .containsExactly("comprovante.pdf");
    }

    @Test
    @DisplayName("3. CNPJ duplicado viola a constraint ao dar flush")
    void duplicateCnpjViolatesConstraint() {
        companyRepository.save(company("Empresa Alfa", "33333333000193"));
        entityManager.flush();

        assertThatThrownBy(() -> companyRepository.save(company("Empresa Beta", "33333333000193")))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    @DisplayName("3. e-mail duplicado viola a constraint ao dar flush")
    void duplicateEmailViolatesConstraint() {
        responsibleRepository.save(responsible("Ana", "ana.duplicada@empresa.com"));
        entityManager.flush();

        assertThatThrownBy(() -> responsibleRepository.save(responsible("Bruno", "ana.duplicada@empresa.com")))
                .isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    @DisplayName("4. CNPJ formatado é salvo só com dígitos e e-mail em minúsculas")
    void normalizesCnpjAndEmail() {
        Company company = company("Empresa Gama", "12.345.678/0001-95");
        companyRepository.save(company);
        Responsible responsible = responsible("Carla", "  Fiscal@Empresa.COM ");
        responsibleRepository.save(responsible);
        entityManager.flush();
        entityManager.clear();

        assertThat(companyRepository.findById(company.getId()).orElseThrow().getCnpj())
                .isEqualTo("12345678000195");
        assertThat(companyRepository.findByCnpj("12345678000195")).isPresent();
        assertThat(responsibleRepository.findById(responsible.getId()).orElseThrow().getEmail())
                .isEqualTo("fiscal@empresa.com");
        assertThat(responsibleRepository.findByEmail("fiscal@empresa.com")).isPresent();
    }

    @Test
    @DisplayName("5. o banco recusa apagar empresa que tenha obrigação")
    void databaseRefusesToDeleteCompanyWithObligation() {
        Company company = companyRepository.save(company("Empresa Com Obrigacao", "44444444000194"));
        Responsible responsible = responsibleRepository.save(responsible("Diego", "diego@empresa.com"));
        obligationRepository.save(obligation(company, responsible, "ECD", LocalDate.of(2026, 6, 30)));
        entityManager.flush();

        entityManager.clear();
        entityManager.remove(entityManager.find(Company.class, company.getId()));
        assertThatThrownBy(() -> entityManager.flush())
                .isInstanceOfAny(DataIntegrityViolationException.class, ConstraintViolationException.class);
    }

    @Test
    @DisplayName("6. filtros por empresa, responsável e status, com paginação")
    void filtersObligationsAndPaginates() {
        Company alpha = companyRepository.save(company("Alpha", "55555555000195"));
        Company beta = companyRepository.save(company("Beta", "66666666000196"));
        Responsible ana = responsibleRepository.save(responsible("Ana", "ana.filtro@empresa.com"));
        Responsible bruno = responsibleRepository.save(responsible("Bruno", "bruno.filtro@empresa.com"));

        obligationRepository.save(obligation(alpha, ana, "DCTF", LocalDate.of(2026, 1, 10)));
        Obligation inProgress = obligation(alpha, bruno, "ECF", LocalDate.of(2026, 2, 10));
        inProgress.changeStatus(ObligationStatus.IN_PROGRESS, Clock.systemUTC());
        obligationRepository.save(inProgress);
        Obligation completed = obligation(beta, ana, "DEFIS", LocalDate.of(2026, 3, 10));
        completed.changeStatus(ObligationStatus.IN_PROGRESS, Clock.systemUTC());
        completed.changeStatus(ObligationStatus.COMPLETED, Clock.systemUTC());
        obligationRepository.save(completed);
        obligationRepository.save(obligation(beta, bruno, "DAS", LocalDate.of(2026, 4, 10)));
        entityManager.flush();
        entityManager.clear();

        PageRequest firstPage = PageRequest.of(0, 10, Sort.by("dueDate"));

        Page<Obligation> byCompany = obligationRepository.findByFilters(
                alpha.getId(), null, null, null, null, firstPage);
        assertThat(byCompany.getTotalElements()).isEqualTo(2);
        assertThat(byCompany.getContent()).extracting(Obligation::getTitle).containsExactly("DCTF", "ECF");
        assertThat(Hibernate.isInitialized(byCompany.getContent().get(0).getCompany())).isTrue();
        assertThat(Hibernate.isInitialized(byCompany.getContent().get(0).getResponsible())).isTrue();

        Page<Obligation> byResponsible = obligationRepository.findByFilters(
                null, ana.getId(), null, null, null, firstPage);
        assertThat(byResponsible.getTotalElements()).isEqualTo(2);
        assertThat(byResponsible.getContent()).extracting(Obligation::getTitle).containsExactly("DCTF", "DEFIS");

        Page<Obligation> byStatus = obligationRepository.findByFilters(
                null, null, ObligationStatus.PENDING, null, null, firstPage);
        assertThat(byStatus.getTotalElements()).isEqualTo(2);
        assertThat(byStatus.getContent()).extracting(Obligation::getTitle).containsExactly("DCTF", "DAS");

        Page<Obligation> byDueDate = obligationRepository.findByFilters(
                null, null, null, LocalDate.of(2026, 2, 1), LocalDate.of(2026, 3, 31), firstPage);
        assertThat(byDueDate.getContent()).extracting(Obligation::getTitle).containsExactly("ECF", "DEFIS");

        Page<Obligation> page = obligationRepository.findAll(PageRequest.of(0, 1, Sort.by("dueDate")));
        assertThat(page.getTotalElements()).isEqualTo(4);
        assertThat(page.getContent()).hasSize(1);
        assertThat(page.getContent().get(0).getTitle()).isEqualTo("DCTF");
        assertThat(Hibernate.isInitialized(page.getContent().get(0).getCompany())).isTrue();

        assertThat(companyRepository.findByActive(false, PageRequest.of(0, 10)).getTotalElements()).isZero();
        assertThat(companyRepository.findByActive(true, PageRequest.of(0, 10)).getTotalElements())
                .isEqualTo(2);
    }

    private Company company(String legalName, String cnpj) {
        Company company = new Company();
        company.setLegalName(legalName);
        company.setCnpj(cnpj);
        return company;
    }

    private Responsible responsible(String name, String email) {
        Responsible responsible = new Responsible();
        responsible.setName(name);
        responsible.setEmail(email);
        responsible.setPasswordHash("hash-nao-deve-aparecer");
        return responsible;
    }

    private Obligation obligation(Company company, Responsible responsible, String title, LocalDate dueDate) {
        Obligation obligation = new Obligation();
        obligation.setCompany(company);
        obligation.setResponsible(responsible);
        obligation.setTitle(title);
        obligation.setDueDate(dueDate);
        return obligation;
    }
}
