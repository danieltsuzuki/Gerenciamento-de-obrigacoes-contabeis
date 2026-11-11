package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.repository;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.repository.AttachmentRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.repository.CompanyRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository.ObligationRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository.ObligationStatusHistoryRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

import java.lang.reflect.Method;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;

class RepositoriesDoNotExposeDeleteTest {

    @ParameterizedTest(name = "{0}")
    @MethodSource("repositories")
    @DisplayName("nenhum repository declara ou herda método cujo nome começa com delete")
    void doesNotExposeDelete(Class<?> repository) {
        for (Method method : repository.getMethods()) {
            assertThat(method.getName())
                    .as(repository.getSimpleName() + "#" + method.getName())
                    .doesNotStartWith("delete");
        }
        for (Method method : repository.getDeclaredMethods()) {
            assertThat(method.getName())
                    .as(repository.getSimpleName() + "#" + method.getName())
                    .doesNotStartWith("delete");
        }
    }

    static Stream<Class<?>> repositories() {
        return Stream.of(
                CompanyRepository.class,
                ResponsibleRepository.class,
                ObligationRepository.class,
                ObligationStatusHistoryRepository.class,
                AttachmentRepository.class
        );
    }
}
