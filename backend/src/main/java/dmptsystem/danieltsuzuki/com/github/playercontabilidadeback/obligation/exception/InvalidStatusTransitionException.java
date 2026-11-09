package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.exception;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;

public class InvalidStatusTransitionException extends RuntimeException {

    private final ObligationStatus from;
    private final ObligationStatus to;

    public InvalidStatusTransitionException(ObligationStatus from, ObligationStatus to) {
        super(from + " → " + to + " não é permitido");
        this.from = from;
        this.to = to;
    }

    public ObligationStatus getFrom() {
        return from;
    }

    public ObligationStatus getTo() {
        return to;
    }
}
