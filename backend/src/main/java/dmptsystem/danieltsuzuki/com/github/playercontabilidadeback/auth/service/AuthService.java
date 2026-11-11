package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.service;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginRequest;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.auth.dto.LoginResponse;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.entity.Responsible;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.mapper.ResponsibleMapper;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.responsible.repository.ResponsibleRepository;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception.BadCredentialsException;
import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.security.JwtService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private static final Logger log = LoggerFactory.getLogger(AuthService.class);

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
        String email = request.email() != null ? request.email().trim().toLowerCase() : "";
        Responsible user = responsibleRepository.findByEmail(email)
                .orElseThrow(() -> {
                    log.warn("Authentication failed - user not found: email='{}'", maskEmail(email));
                    return new BadCredentialsException("Credenciais inválidas.");
                });

        if (!user.isActive()) {
            log.warn("Authentication failed - user inactive: id={}, email='{}'", user.getId(), maskEmail(user.getEmail()));
            throw new BadCredentialsException("Usuário inativo. Acesso não permitido.");
        }

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            log.warn("Authentication failed - invalid password: id={}, email='{}'", user.getId(), maskEmail(user.getEmail()));
            throw new BadCredentialsException("Credenciais inválidas.");
        }

        String token = jwtService.generateToken(user);
        long expiresIn = jwtService.getExpirationSeconds();

        log.info("User authenticated successfully: id={}, email='{}'", user.getId(), user.getEmail());

        return new LoginResponse(
                token,
                "Bearer",
                expiresIn,
                responsibleMapper.toResponse(user)
        );
    }

    private String maskEmail(String email) {
        if (email == null || !email.contains("@")) {
            return "***";
        }
        int atIndex = email.indexOf('@');
        String local = email.substring(0, atIndex);
        String domain = email.substring(atIndex);
        if (local.length() <= 1) {
            return "*..." + domain;
        }
        return local.charAt(0) + "***" + domain;
    }
}

