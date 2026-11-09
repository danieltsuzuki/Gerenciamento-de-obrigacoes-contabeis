package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;

class ObligationStatusTest {

    @ParameterizedTest(name = "{0} → {1}")
    @MethodSource("allowedTransitions")
    @DisplayName("permite somente PENDING → IN_PROGRESS e IN_PROGRESS → COMPLETED")
    void allowsTransition(ObligationStatus from, ObligationStatus to) {
        assertThat(from.canTransitionTo(to)).isTrue();
    }

    @ParameterizedTest(name = "{0} → {1}")
    @MethodSource("forbiddenTransitions")
    @DisplayName("rejeita transições fora da sequência, inclusive para o mesmo status")
    void rejectsTransition(ObligationStatus from, ObligationStatus to) {
        assertThat(from.canTransitionTo(to)).isFalse();
    }

    static Stream<Arguments> allowedTransitions() {
        return Stream.of(
                Arguments.of(ObligationStatus.PENDING, ObligationStatus.IN_PROGRESS),
                Arguments.of(ObligationStatus.IN_PROGRESS, ObligationStatus.COMPLETED)
        );
    }

    static Stream<Arguments> forbiddenTransitions() {
        return Stream.of(
                Arguments.of(ObligationStatus.PENDING, ObligationStatus.COMPLETED),
                Arguments.of(ObligationStatus.IN_PROGRESS, ObligationStatus.PENDING),
                Arguments.of(ObligationStatus.COMPLETED, ObligationStatus.IN_PROGRESS),
                Arguments.of(ObligationStatus.COMPLETED, ObligationStatus.PENDING),
                Arguments.of(ObligationStatus.PENDING, ObligationStatus.PENDING),
                Arguments.of(ObligationStatus.IN_PROGRESS, ObligationStatus.IN_PROGRESS),
                Arguments.of(ObligationStatus.COMPLETED, ObligationStatus.COMPLETED)
        );
    }
}
