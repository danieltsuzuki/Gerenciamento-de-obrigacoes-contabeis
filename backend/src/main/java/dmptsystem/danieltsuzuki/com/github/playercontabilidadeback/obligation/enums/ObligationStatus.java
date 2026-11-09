package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums;

public enum ObligationStatus {
    PENDING,
    IN_PROGRESS,
    COMPLETED;

    public boolean canTransitionTo(ObligationStatus next) {
        return switch (this) {
            case PENDING -> next == IN_PROGRESS;
            case IN_PROGRESS -> next == COMPLETED;
            case COMPLETED -> false;
        };
    }
}
