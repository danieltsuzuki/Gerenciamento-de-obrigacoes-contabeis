package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.exception.InvalidStatusTransitionException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class ObligationChangeStatusTest {

    private static final Clock CLOCK = Clock.fixed(
            Instant.parse("2026-11-07T18:45:00Z"),
            ZoneOffset.UTC
    );

    @Test
    @DisplayName("nasce PENDING com completedAt nulo e preenche completedAt só ao concluir")
    void fillsCompletedAtOnlyWhenCompleted() {
        Obligation obligation = new Obligation();

        assertThat(obligation.getStatus()).isEqualTo(ObligationStatus.PENDING);
        assertThat(obligation.getCompletedAt()).isNull();

        obligation.changeStatus(ObligationStatus.IN_PROGRESS, CLOCK);

        assertThat(obligation.getStatus()).isEqualTo(ObligationStatus.IN_PROGRESS);
        assertThat(obligation.getCompletedAt()).isNull();

        obligation.changeStatus(ObligationStatus.COMPLETED, CLOCK);

        assertThat(obligation.getStatus()).isEqualTo(ObligationStatus.COMPLETED);
        assertThat(obligation.getCompletedAt()).isEqualTo(LocalDateTime.of(2026, 11, 7, 18, 45));
    }

    @Test
    @DisplayName("transição rejeitada não altera status nem completedAt")
    void rejectedTransitionLeavesStateUntouched() {
        Obligation obligation = new Obligation();
        obligation.changeStatus(ObligationStatus.IN_PROGRESS, CLOCK);
        obligation.changeStatus(ObligationStatus.COMPLETED, CLOCK);
        LocalDateTime completedAt = obligation.getCompletedAt();

        assertThatThrownBy(() -> obligation.changeStatus(ObligationStatus.IN_PROGRESS, CLOCK))
                .isInstanceOf(InvalidStatusTransitionException.class)
                .hasMessageContaining("COMPLETED")
                .hasMessageContaining("IN_PROGRESS");

        assertThat(obligation.getStatus()).isEqualTo(ObligationStatus.COMPLETED);
        assertThat(obligation.getCompletedAt()).isEqualTo(completedAt);
    }

    @Test
    @DisplayName("tentativa de concluir direto de PENDING (salto) é rejeitada e não preenche completedAt")
    void rejectedCompletionDoesNotSetCompletedAt() {
        Obligation obligation = new Obligation();

        assertThatThrownBy(() -> obligation.changeStatus(ObligationStatus.COMPLETED, CLOCK))
                .isInstanceOf(InvalidStatusTransitionException.class);

        assertThat(obligation.getStatus()).isEqualTo(ObligationStatus.PENDING);
        assertThat(obligation.getCompletedAt()).isNull();
    }

    @Test
    @DisplayName("transição para null é rejeitada com InvalidStatusTransitionException")
    void rejectedNullTransition() {
        Obligation obligation = new Obligation();

        assertThatThrownBy(() -> obligation.changeStatus(null, CLOCK))
                .isInstanceOf(InvalidStatusTransitionException.class);

        assertThat(obligation.getStatus()).isEqualTo(ObligationStatus.PENDING);
        assertThat(obligation.getCompletedAt()).isNull();
    }

    @ParameterizedTest(name = "a partir de {0}, transição para {1} deve ser rejeitada")
    @MethodSource("invalidTransitions")
    @DisplayName("garante que todas as transições inválidas (regressões, saltos, mesmo status) são rejeitadas pelo domínio")
    void rejectsAllForbiddenTransitionsInDomain(ObligationStatus from, ObligationStatus to) {
        Obligation obligation = new Obligation();
        if (from == ObligationStatus.IN_PROGRESS) {
            obligation.changeStatus(ObligationStatus.IN_PROGRESS, CLOCK);
        } else if (from == ObligationStatus.COMPLETED) {
            obligation.changeStatus(ObligationStatus.IN_PROGRESS, CLOCK);
            obligation.changeStatus(ObligationStatus.COMPLETED, CLOCK);
        }

        LocalDateTime initialCompletedAt = obligation.getCompletedAt();

        assertThatThrownBy(() -> obligation.changeStatus(to, CLOCK))
                .isInstanceOf(InvalidStatusTransitionException.class);

        assertThat(obligation.getStatus()).isEqualTo(from);
        assertThat(obligation.getCompletedAt()).isEqualTo(initialCompletedAt);
    }

    static Stream<Arguments> invalidTransitions() {
        return Stream.of(
                // Saltos
                Arguments.of(ObligationStatus.PENDING, ObligationStatus.COMPLETED),
                // Regressões
                Arguments.of(ObligationStatus.IN_PROGRESS, ObligationStatus.PENDING),
                Arguments.of(ObligationStatus.COMPLETED, ObligationStatus.IN_PROGRESS),
                Arguments.of(ObligationStatus.COMPLETED, ObligationStatus.PENDING),
                // Mesmo status (idempotência proibida)
                Arguments.of(ObligationStatus.PENDING, ObligationStatus.PENDING),
                Arguments.of(ObligationStatus.IN_PROGRESS, ObligationStatus.IN_PROGRESS),
                Arguments.of(ObligationStatus.COMPLETED, ObligationStatus.COMPLETED)
        );
    }
}
