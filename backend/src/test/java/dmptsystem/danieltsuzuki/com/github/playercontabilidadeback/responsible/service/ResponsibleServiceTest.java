package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.CreateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.ResponsibleResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.dto.UpdateResponsibleRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.mapper.ResponsibleMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.DuplicateResourceException;
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
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ResponsibleServiceTest {

    @Mock
    private ResponsibleRepository responsibleRepository;

    @Mock
    private ResponsibleMapper responsibleMapper;

    @Mock
    private PasswordEncoder passwordEncoder;

    private ResponsibleService responsibleService;

    @BeforeEach
    void setUp() {
        responsibleService = new ResponsibleService(responsibleRepository, responsibleMapper, passwordEncoder);
    }

    @Test
    @DisplayName("Deve criar responsável com sucesso quando e-mail for único")
    void shouldCreateResponsibleSuccessfully() {
        CreateResponsibleRequest request = new CreateResponsibleRequest("Carlos Silva", "carlos@empresa.com", "senha123", true);
        Responsible mappedEntity = new Responsible();
        mappedEntity.setName("Carlos Silva");
        mappedEntity.setEmail("carlos@empresa.com");

        Responsible saved = new Responsible();
        saved.setId(1L);
        saved.setName("Carlos Silva");
        saved.setEmail("carlos@empresa.com");
        saved.setPasswordHash("hashed_senha123");
        saved.setActive(true);

        ResponsibleResponse expectedResponse = new ResponsibleResponse(1L, "Carlos Silva", "carlos@empresa.com", true, LocalDateTime.now(), LocalDateTime.now());

        when(responsibleRepository.existsByEmail("carlos@empresa.com")).thenReturn(false);
        when(responsibleMapper.toEntity(request)).thenReturn(mappedEntity);
        when(passwordEncoder.encode("senha123")).thenReturn("hashed_senha123");
        when(responsibleRepository.save(any(Responsible.class))).thenReturn(saved);
        when(responsibleMapper.toResponse(saved)).thenReturn(expectedResponse);

        ResponsibleResponse actual = responsibleService.create(request);

        assertThat(actual).isNotNull();
        assertThat(actual.email()).isEqualTo("carlos@empresa.com");
        verify(passwordEncoder).encode("senha123");
        verify(responsibleRepository).save(any(Responsible.class));
    }

    @Test
    @DisplayName("Deve lançar DuplicateResourceException quando e-mail já existir ao criar")
    void shouldThrowWhenEmailAlreadyExistsOnCreate() {
        CreateResponsibleRequest request = new CreateResponsibleRequest("Carlos Silva", "carlos@empresa.com", "senha123", true);
        when(responsibleRepository.existsByEmail("carlos@empresa.com")).thenReturn(true);

        assertThatThrownBy(() -> responsibleService.create(request))
                .isInstanceOf(DuplicateResourceException.class)
                .hasMessageContaining("E-mail já cadastrado");

        verify(responsibleRepository, never()).save(any());
    }

    @Test
    @DisplayName("Deve buscar responsável por ID com sucesso")
    void shouldFindByIdSuccessfully() {
        Responsible entity = new Responsible();
        entity.setId(1L);
        entity.setName("Carlos Silva");
        ResponsibleResponse response = new ResponsibleResponse(1L, "Carlos Silva", "carlos@empresa.com", true, LocalDateTime.now(), LocalDateTime.now());

        when(responsibleRepository.findById(1L)).thenReturn(Optional.of(entity));
        when(responsibleMapper.toResponse(entity)).thenReturn(response);

        ResponsibleResponse actual = responsibleService.findById(1L);

        assertThat(actual).isNotNull();
        assertThat(actual.id()).isEqualTo(1L);
    }

    @Test
    @DisplayName("Deve lançar NotFoundException quando responsável não existir por ID")
    void shouldThrowNotFoundExceptionWhenIdNotFound() {
        when(responsibleRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> responsibleService.findById(99L))
                .isInstanceOf(NotFoundException.class)
                .hasMessageContaining("99");
    }

    @Test
    @DisplayName("Deve listar responsáveis com paginação")
    void shouldFindAllWithPagination() {
        Pageable pageable = PageRequest.of(0, 10);
        Responsible entity = new Responsible();
        entity.setId(1L);
        entity.setName("Carlos");
        ResponsibleResponse response = new ResponsibleResponse(1L, "Carlos", "carlos@empresa.com", true, LocalDateTime.now(), LocalDateTime.now());

        when(responsibleRepository.findByActive(eq(true), eq(pageable)))
                .thenReturn(new PageImpl<>(List.of(entity), pageable, 1));
        when(responsibleMapper.toResponse(entity)).thenReturn(response);

        Page<ResponsibleResponse> page = responsibleService.findAll(true, pageable);

        assertThat(page.getTotalElements()).isEqualTo(1);
        assertThat(page.getContent().getFirst().name()).isEqualTo("Carlos");
    }

    @Test
    @DisplayName("Deve atualizar responsável com sucesso")
    void shouldUpdateResponsibleSuccessfully() {
        Responsible entity = new Responsible();
        entity.setId(1L);
        entity.setName("Carlos Antigo");
        entity.setEmail("carlos@empresa.com");
        entity.setPasswordHash("oldHash");
        entity.setActive(true);

        UpdateResponsibleRequest updateRequest = new UpdateResponsibleRequest("Carlos Novo", "carlos.novo@empresa.com", false);
        ResponsibleResponse expectedResponse = new ResponsibleResponse(1L, "Carlos Novo", "carlos.novo@empresa.com", false, LocalDateTime.now(), LocalDateTime.now());

        when(responsibleRepository.findById(1L)).thenReturn(Optional.of(entity));
        when(responsibleRepository.existsByEmailAndIdNot("carlos.novo@empresa.com", 1L)).thenReturn(false);
        when(responsibleRepository.save(entity)).thenReturn(entity);
        when(responsibleMapper.toResponse(entity)).thenReturn(expectedResponse);

        ResponsibleResponse actual = responsibleService.update(1L, updateRequest);

        assertThat(actual.name()).isEqualTo("Carlos Novo");
        assertThat(actual.active()).isFalse();
    }

    @Test
    @DisplayName("Deve lançar DuplicateResourceException quando e-mail pertencer a outro no update")
    void shouldThrowDuplicateEmailOnUpdate() {
        Responsible entity = new Responsible();
        entity.setId(1L);
        entity.setEmail("carlos@empresa.com");

        UpdateResponsibleRequest updateRequest = new UpdateResponsibleRequest("Carlos", "outro@empresa.com", true);

        when(responsibleRepository.findById(1L)).thenReturn(Optional.of(entity));
        when(responsibleRepository.existsByEmailAndIdNot("outro@empresa.com", 1L)).thenReturn(true);

        assertThatThrownBy(() -> responsibleService.update(1L, updateRequest))
                .isInstanceOf(DuplicateResourceException.class)
                .hasMessageContaining("E-mail já cadastrado");

        verify(responsibleRepository, never()).save(any());
    }

    @Test
    @DisplayName("deve delegar para search quando q for informado")
    void shouldDelegateToSearchWhenQIsProvided() {
        Responsible responsible = new Responsible();
        responsible.setName("Carlos Contador");
        responsible.setEmail("carlos@empresa.com");
        Page<Responsible> page = new PageImpl<>(List.of(responsible));
        Pageable pageable = PageRequest.of(0, 10);

        ResponsibleResponse expectedResponse = new ResponsibleResponse(1L, "Carlos Contador", "carlos@empresa.com", true, java.time.LocalDateTime.now(), java.time.LocalDateTime.now());
        when(responsibleRepository.search(true, "carlos", pageable)).thenReturn(page);
        when(responsibleMapper.toResponse(responsible)).thenReturn(expectedResponse);

        Page<ResponsibleResponse> result = responsibleService.findAll(true, "carlos", pageable);

        assertThat(result.getContent()).hasSize(1);
        assertThat(result.getContent().get(0).name()).isEqualTo("Carlos Contador");
    }

    @Test
    @DisplayName("deve lançar SearchQueryTooLongException quando q tiver mais de 100 caracteres")
    void shouldThrowWhenQExceeds100Chars() {
        Pageable pageable = PageRequest.of(0, 10);
        assertThatThrownBy(() -> responsibleService.findAll(null, "b".repeat(101), pageable))
                .isInstanceOf(dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.SearchQueryTooLongException.class)
                .hasMessageContaining("100 caracteres");
    }
}
