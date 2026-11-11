package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.ObligationStatusHistory;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.repository.Repository;

import java.util.List;
import java.util.Optional;

public interface ObligationStatusHistoryRepository extends Repository<ObligationStatusHistory, Long> {

    ObligationStatusHistory save(ObligationStatusHistory history);

    @EntityGraph(attributePaths = {"changedBy"})
    List<ObligationStatusHistory> findByObligationIdOrderByChangedAtAscIdAsc(Long obligationId);

    Optional<ObligationStatusHistory> findById(Long id);
}

