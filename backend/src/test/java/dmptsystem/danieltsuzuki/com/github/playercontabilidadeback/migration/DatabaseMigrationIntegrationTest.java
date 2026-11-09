package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.migration;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.AbstractIntegrationTest;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.jdbc.core.JdbcTemplate;

import java.time.LocalDate;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class DatabaseMigrationIntegrationTest extends AbstractIntegrationTest {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Test
    @DisplayName("1. A migration V1 aplica com sucesso em banco vazio e cria as 4 tabelas")
    void shouldApplyMigrationOnEmptyDatabase() {
        Integer flywayInstalledMigrations = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM flyway_schema_history WHERE success = 1 AND version = '1'",
                Integer.class
        );
        assertThat(flywayInstalledMigrations).isEqualTo(1);

        Integer companyCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM company", Integer.class);
        Integer usersCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM users", Integer.class);
        Integer obligationCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM obligation", Integer.class);
        Integer attachmentCount = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM attachment", Integer.class);

        assertThat(companyCount).isNotNull();
        assertThat(usersCount).isNotNull();
        assertThat(obligationCount).isNotNull();
        assertThat(attachmentCount).isNotNull();
    }

    @Test
    @DisplayName("2. CNPJ duplicado é rejeitado pelo banco (UNIQUE CONSTRAINT uk_company_cnpj)")
    void shouldRejectDuplicateCnpj() {
        String cnpj = "12345678000195";
        jdbcTemplate.update("INSERT INTO company (legal_name, cnpj) VALUES (?, ?)", "Empresa Alpha", cnpj);

        assertThatThrownBy(() ->
                jdbcTemplate.update("INSERT INTO company (legal_name, cnpj) VALUES (?, ?)", "Empresa Beta", cnpj)
        ).isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    @DisplayName("3. E-mail duplicado é rejeitado pelo banco (UNIQUE CONSTRAINT uk_users_email)")
    void shouldRejectDuplicateEmail() {
        String email = "contato@empresa.com";
        jdbcTemplate.update(
                "INSERT INTO users (name, email, password) VALUES (?, ?, ?)",
                "Usuario Alpha", email, "$2a$10$fictitiousHashForTest"
        );

        assertThatThrownBy(() ->
                jdbcTemplate.update(
                        "INSERT INTO users (name, email, password) VALUES (?, ?, ?)",
                        "Usuario Beta", email, "$2a$10$anotherFictitiousHash"
                )
        ).isInstanceOf(DataIntegrityViolationException.class);
    }

    @Test
    @DisplayName("4. O banco recusa apagar uma empresa que tenha obrigação vinculada (FK sem cascade)")
    void shouldRefuseToDeleteCompanyWithObligations() {
        jdbcTemplate.update(
                "INSERT INTO company (id, legal_name, cnpj) VALUES (?, ?, ?)",
                100L, "Empresa Com Obrigacao", "98765432000188"
        );
        jdbcTemplate.update(
                "INSERT INTO users (id, name, email, password) VALUES (?, ?, ?, ?)",
                100L, "Responsavel Fiscal", "fiscal100@empresa.com", "$2a$10$hash"
        );
        jdbcTemplate.update(
                "INSERT INTO obligation (id, company_id, responsible_id, title, status, due_date) VALUES (?, ?, ?, ?, ?, ?)",
                100L, 100L, 100L, "DCTF Mensal", "PENDING", LocalDate.now().plusDays(15)
        );

        assertThatThrownBy(() ->
                jdbcTemplate.update("DELETE FROM company WHERE id = ?", 100L)
        ).isInstanceOf(DataIntegrityViolationException.class);
    }
}

