package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto.CompanySummaryResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleSummaryResponse;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record ObligationDetailResponse(
        Long id,
        CompanySummaryResponse company,
        ResponsibleSummaryResponse responsible,
        String title,
        String description,
        ObligationStatus status,
        LocalDate dueDate,
        long attachmentCount,
        LocalDateTime completedAt,
        LocalDateTime createdAt,
        LocalDateTime updatedAt
) {
}

