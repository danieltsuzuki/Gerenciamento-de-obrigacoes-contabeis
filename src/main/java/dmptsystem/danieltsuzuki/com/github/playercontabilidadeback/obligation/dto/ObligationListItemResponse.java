package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanySummaryResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleSummaryResponse;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record ObligationListItemResponse(
        Long id,
        CompanySummaryResponse company,
        ResponsibleSummaryResponse responsible,
        String title,
        ObligationStatus status,
        LocalDate dueDate,
        long attachmentCount,
        LocalDateTime createdAt,
        LocalDateTime completedAt
) {
}

