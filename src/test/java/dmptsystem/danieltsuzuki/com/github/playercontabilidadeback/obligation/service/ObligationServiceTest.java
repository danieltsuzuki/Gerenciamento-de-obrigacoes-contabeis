package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.attachment.repository.AttachmentRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.entity.Company;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.repository.CompanyRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.CreateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationDetailResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationListItemResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.ObligationWithAttachmentCount;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.dto.UpdateObligationRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.entity.Obligation;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.enums.ObligationStatus;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.exception.InvalidStatusTransitionException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.mapper.ObligationMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.obligation.repository.ObligationRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BusinessRuleException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.NotFoundException;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

import java.time.Clock;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ObligationServiceTest {

    @Mock
    private ObligationRepository obligationRepository;

    @Mock
    private CompanyRepository companyRepository;

    @Mock
    private ResponsibleRepository responsibleRepository;

    @Mock
    private AttachmentRepository attachmentRepository;

    private final ObligationMapper obligationMapper = new ObligationMapper();
    private final Clock clock = Clock.fixed(Instant.parse("2026-11-08T12:00:00Z"), ZoneOffset.UTC);

    private ObligationService obligationService;

    @BeforeEach
    void setUp() {
        obligationService = new ObligationService(
                obligationRepository,
                companyRepository,
                responsibleRepository,
                attachmentRepository,
                obligationMapper,
                clock
        );
    }

    @Test
    @DisplayName("Deve criar obrigação com sucesso quando empresa e responsável forem ativos")
    void shouldCreateObligationSuccessfully() {
        Company company = new Company();
        company.setId(1L);
        company.setActive(true);

        Responsible responsible = new Responsible();
        responsible.setId(2L);
        responsible.setActive(true);

        CreateObligationRequest request = new CreateObligationRequest(
                1L, 2L, "DEFIS 2026", "Declaração anual", LocalDate.of(2026, 3, 31)
        );

        when(companyRepository.findById(1L)).thenReturn(Optional.of(company));
        when(responsibleRepository.findById(2L)).thenReturn(Optional.of(responsible));
        when(obligationRepository.save(any(Obligation.class))).thenAnswer(invocation -> {
            Obligation o = invocation.getArgument(0);
            return o;
        });

        ObligationDetailResponse response = obligationService.create(request);

        assertThat(response).isNotNull();
        assertThat(response.title()).isEqualTo("DEFIS 2026");
        assertThat(response.status()).isEqualTo(ObligationStatus.PENDING);
        assertThat(response.attachmentCount()).isEqualTo(0L);
        verify(obligationRepository).save(any(Obligation.class));
    }

    @Test
    @DisplayName("Deve lançar BusinessRuleException (COMPANY_INACTIVE) se empresa estiver inativa ao criar")
    void shouldThrowWhenCompanyIsInactiveOnCreate() {
        Company company = new Company();
        company.setId(1L);
        company.setActive(false);

        CreateObligationRequest request = new CreateObligationRequest(
                1L, 2L, "DEFIS 2026", null, LocalDate.of(2026, 3, 31)
        );

        when(companyRepository.findById(1L)).thenReturn(Optional.of(company));

        assertThatThrownBy(() -> obligationService.create(request))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(e -> assertThat(((BusinessRuleException) e).getCode()).isEqualTo("COMPANY_INACTIVE"));

        verify(obligationRepository, never()).save(any());
    }

    @Test
    @DisplayName("Deve lançar BusinessRuleException (USER_INACTIVE) se responsável estiver inativo ao criar")
    void shouldThrowWhenResponsibleIsInactiveOnCreate() {
        Company company = new Company();
        company.setId(1L);
        company.setActive(true);

        Responsible responsible = new Responsible();
        responsible.setId(2L);
        responsible.setActive(false);

        CreateObligationRequest request = new CreateObligationRequest(
                1L, 2L, "DEFIS 2026", null, LocalDate.of(2026, 3, 31)
        );

        when(companyRepository.findById(1L)).thenReturn(Optional.of(company));
        when(responsibleRepository.findById(2L)).thenReturn(Optional.of(responsible));

        assertThatThrownBy(() -> obligationService.create(request))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(e -> assertThat(((BusinessRuleException) e).getCode()).isEqualTo("USER_INACTIVE"));

        verify(obligationRepository, never()).save(any());
    }

    @Test
    @DisplayName("Deve buscar por ID com contagem de anexos")
    void shouldFindByIdWithAttachmentCount() {
        Company company = new Company();
        company.setId(1L);

        Responsible responsible = new Responsible();
        responsible.setId(2L);

        Obligation obligation = new Obligation();
        obligation.setCompany(company);
        obligation.setResponsible(responsible);
        obligation.setTitle("DAS Simples");
        obligation.setDueDate(LocalDate.of(2026, 5, 20));

        when(obligationRepository.findById(10L)).thenReturn(Optional.of(obligation));
        when(attachmentRepository.countByObligationId(10L)).thenReturn(3L);

        ObligationDetailResponse response = obligationService.findById(10L);

        assertThat(response.title()).isEqualTo("DAS Simples");
        assertThat(response.attachmentCount()).isEqualTo(3L);
    }

    @Test
    @DisplayName("Deve lançar NotFoundException quando ID não existir")
    void shouldThrowNotFoundExceptionWhenIdDoesNotExist() {
        when(obligationRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> obligationService.findById(99L))
                .isInstanceOf(NotFoundException.class);
    }

    @Test
    @DisplayName("Deve atualizar campos e realizar transição de status PENDING -> IN_PROGRESS")
    void shouldUpdateAndTransitionStatus() {
        Company company = new Company();
        company.setId(1L);

        Responsible responsible = new Responsible();
        responsible.setId(2L);

        Obligation obligation = new Obligation();
        obligation.setCompany(company);
        obligation.setResponsible(responsible);
        obligation.setTitle("DAS Simples Antigo");
        obligation.setDueDate(LocalDate.of(2026, 5, 20));

        when(obligationRepository.findById(10L)).thenReturn(Optional.of(obligation));
        when(obligationRepository.save(any(Obligation.class))).thenAnswer(i -> i.getArgument(0));
        when(attachmentRepository.countByObligationId(10L)).thenReturn(1L);

        UpdateObligationRequest updateRequest = new UpdateObligationRequest(
                1L, 2L, "DAS Simples Novo", "Observação", LocalDate.of(2026, 5, 22), ObligationStatus.IN_PROGRESS
        );

        ObligationDetailResponse response = obligationService.update(10L, updateRequest);

        assertThat(response.title()).isEqualTo("DAS Simples Novo");
        assertThat(response.status()).isEqualTo(ObligationStatus.IN_PROGRESS);
        assertThat(response.attachmentCount()).isEqualTo(1L);
    }

    @Test
    @DisplayName("Deve rejeitar transição inválida de status PENDING -> COMPLETED")
    void shouldRejectInvalidStatusTransition() {
        Company company = new Company();
        company.setId(1L);

        Responsible responsible = new Responsible();
        responsible.setId(2L);

        Obligation obligation = new Obligation();
        obligation.setCompany(company);
        obligation.setResponsible(responsible);
        obligation.setTitle("DAS Simples");
        obligation.setDueDate(LocalDate.of(2026, 5, 20));

        when(obligationRepository.findById(10L)).thenReturn(Optional.of(obligation));

        UpdateObligationRequest updateRequest = new UpdateObligationRequest(
                1L, 2L, "DAS Simples", null, LocalDate.of(2026, 5, 20), ObligationStatus.COMPLETED
        );

        assertThatThrownBy(() -> obligationService.update(10L, updateRequest))
                .isInstanceOf(InvalidStatusTransitionException.class);
    }

    @Test
    @DisplayName("Não deve revalidar empresa/usuário inativo se IDs não forem alterados no update")
    void shouldNotRevalidateInactiveWhenIdsUnchanged() {
        Company company = new Company();
        company.setId(1L);
        company.setActive(false); // Inativa agora, mas já era dona da obrigação

        Responsible responsible = new Responsible();
        responsible.setId(2L);
        responsible.setActive(false); // Inativo agora

        Obligation obligation = new Obligation();
        obligation.setCompany(company);
        obligation.setResponsible(responsible);
        obligation.setTitle("Título Antigo");
        obligation.setDueDate(LocalDate.of(2026, 5, 20));

        when(obligationRepository.findById(10L)).thenReturn(Optional.of(obligation));
        when(obligationRepository.save(any(Obligation.class))).thenAnswer(i -> i.getArgument(0));

        UpdateObligationRequest updateRequest = new UpdateObligationRequest(
                1L, 2L, "Título Atualizado", null, LocalDate.of(2026, 5, 20), null
        );

        ObligationDetailResponse response = obligationService.update(10L, updateRequest);

        assertThat(response.title()).isEqualTo("Título Atualizado");
        verify(companyRepository, never()).findById(any());
        verify(responsibleRepository, never()).findById(any());
    }

    @Test
    @DisplayName("Deve validar novo responsável caso ID seja alterado no update")
    void shouldValidateNewResponsibleWhenChangedOnUpdate() {
        Company company = new Company();
        company.setId(1L);

        Responsible oldResp = new Responsible();
        oldResp.setId(2L);

        Responsible newResp = new Responsible();
        newResp.setId(3L);
        newResp.setActive(false);

        Obligation obligation = new Obligation();
        obligation.setCompany(company);
        obligation.setResponsible(oldResp);
        obligation.setTitle("Obrigação");
        obligation.setDueDate(LocalDate.of(2026, 5, 20));

        when(obligationRepository.findById(10L)).thenReturn(Optional.of(obligation));
        when(responsibleRepository.findById(3L)).thenReturn(Optional.of(newResp));

        UpdateObligationRequest updateRequest = new UpdateObligationRequest(
                1L, 3L, "Obrigação", null, LocalDate.of(2026, 5, 20), null
        );

        assertThatThrownBy(() -> obligationService.update(10L, updateRequest))
                .isInstanceOf(BusinessRuleException.class)
                .satisfies(e -> assertThat(((BusinessRuleException) e).getCode()).isEqualTo("USER_INACTIVE"));
    }
}

