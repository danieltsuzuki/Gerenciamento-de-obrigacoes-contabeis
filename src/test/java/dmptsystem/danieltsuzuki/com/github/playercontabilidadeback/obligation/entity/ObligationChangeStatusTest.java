package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.exception.InvalidStatusTransitionException;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneOffset;

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
    @DisplayName("tentativa de concluir direto de PENDING não preenche completedAt")
    void rejectedCompletionDoesNotSetCompletedAt() {
        Obligation obligation = new Obligation();

        assertThatThrownBy(() -> obligation.changeStatus(ObligationStatus.COMPLETED, CLOCK))
                .isInstanceOf(InvalidStatusTransitionException.class);

        assertThat(obligation.getStatus()).isEqualTo(ObligationStatus.PENDING);
        assertThat(obligation.getCompletedAt()).isNull();
    }
}
