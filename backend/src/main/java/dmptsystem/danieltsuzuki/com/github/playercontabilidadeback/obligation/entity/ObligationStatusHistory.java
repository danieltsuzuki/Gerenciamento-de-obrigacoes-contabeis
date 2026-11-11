package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.Objects;

@Entity
@Table(name = "obligation_status_history")
public class ObligationStatusHistory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "obligation_id", nullable = false)
    private Obligation obligation;

    @Enumerated(EnumType.STRING)
    @Column(name = "from_status", length = 20)
    private ObligationStatus fromStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "to_status", nullable = false, length = 20)
    private ObligationStatus toStatus;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "changed_by")
    private Responsible changedBy;

    @Column(name = "changed_at", nullable = false, updatable = false)
    private LocalDateTime changedAt;

    public ObligationStatusHistory() {
    }

    public ObligationStatusHistory(Obligation obligation, ObligationStatus fromStatus, ObligationStatus toStatus, Responsible changedBy) {
        this.obligation = obligation;
        this.fromStatus = fromStatus;
        this.toStatus = toStatus;
        this.changedBy = changedBy;
    }

    @PrePersist
    void onPersist() {
        if (changedAt == null) {
            changedAt = LocalDateTime.now(ZoneOffset.UTC);
        }
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Obligation getObligation() {
        return obligation;
    }

    public void setObligation(Obligation obligation) {
        this.obligation = obligation;
    }

    public ObligationStatus getFromStatus() {
        return fromStatus;
    }

    public void setFromStatus(ObligationStatus fromStatus) {
        this.fromStatus = fromStatus;
    }

    public ObligationStatus getToStatus() {
        return toStatus;
    }

    public void setToStatus(ObligationStatus toStatus) {
        this.toStatus = toStatus;
    }

    public Responsible getChangedBy() {
        return changedBy;
    }

    public void setChangedBy(Responsible changedBy) {
        this.changedBy = changedBy;
    }

    public LocalDateTime getChangedAt() {
        return changedAt;
    }

    public void setChangedAt(LocalDateTime changedAt) {
        this.changedAt = changedAt;
    }

    @Override
    public boolean equals(Object other) {
        if (this == other) {
            return true;
        }
        if (!(other instanceof ObligationStatusHistory that)) {
            return false;
        }
        return id != null && id.equals(that.id);
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(id);
    }

    @Override
    public String toString() {
        return "ObligationStatusHistory{"
                + "id=" + id
                + ", fromStatus=" + fromStatus
                + ", toStatus=" + toStatus
                + ", changedAt=" + changedAt
                + '}';
    }
}

