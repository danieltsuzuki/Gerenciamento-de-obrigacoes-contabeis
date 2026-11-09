package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.tags.Tag;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    public static final String SECURITY_SCHEME_NAME = "bearerAuth";

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Player Contabilidade - API de Gestão de Obrigações Fiscais")
                        .description("API REST para gestão de empresas clientes, responsáveis contábeis, obrigações fiscais e anexos comprobatórios com auditoria e controle de ciclo de vida.")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Equipe Player Contabilidade")
                                .email("contato@playercontabilidade.com.br")))
                .tags(List.of(
                        new Tag().name("Autenticação").description("Operações públicas de login e registro de usuários"),
                        new Tag().name("Empresas").description("Gerenciamento de empresas clientes e inativação (soft delete)"),
                        new Tag().name("Responsáveis").description("Gerenciamento de responsáveis contábeis e inativação"),
                        new Tag().name("Obrigações").description("Ciclo de vida, agendamento e máquina de estados das obrigações fiscais"),
                        new Tag().name("Anexos").description("Upload, consulta e download seguro de arquivos anexados às obrigações")
                ))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME))
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME, new SecurityScheme()
                                .name(SECURITY_SCHEME_NAME)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("Informe o token JWT (sem o prefixo 'Bearer ') obtido em /api/auth/login")));
    }
}

