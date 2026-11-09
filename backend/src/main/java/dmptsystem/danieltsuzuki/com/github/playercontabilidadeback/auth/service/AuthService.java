package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.mapper.ResponsibleMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BadCredentialsException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final ResponsibleRepository responsibleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final ResponsibleMapper responsibleMapper;

    public AuthService(ResponsibleRepository responsibleRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService,
                       ResponsibleMapper responsibleMapper) {
        this.responsibleRepository = responsibleRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.responsibleMapper = responsibleMapper;
    }

    @Transactional(readOnly = true)
    public LoginResponse login(LoginRequest request) {
        Responsible user = responsibleRepository.findByEmail(request.email().trim().toLowerCase())
                .orElseThrow(() -> new BadCredentialsException("Credenciais inválidas."));

        if (!user.isActive()) {
            throw new BadCredentialsException("Usuário inativo. Acesso não permitido.");
        }

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new BadCredentialsException("Credenciais inválidas.");
        }

        String token = jwtService.generateToken(user);
        long expiresIn = jwtService.getExpirationSeconds();

        return new LoginResponse(
                token,
                "Bearer",
                expiresIn,
                responsibleMapper.toResponse(user)
        );
    }
}

