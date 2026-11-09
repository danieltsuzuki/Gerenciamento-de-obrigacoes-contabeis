package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.validator.ValidCnpj;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Schema(description = "Dados para atualização de empresa")
public record UpdateCompanyRequest(
        @Schema(description = "Razão social da empresa", example = "Alpha Contabilidade Ltda")
        @NotBlank(message = "Razão social é obrigatória")
        @Size(max = 255, message = "Razão social deve ter no máximo 255 caracteres")
        String legalName,

        @Schema(description = "Nome fantasia", example = "Alpha Global")
        @Size(max = 255, message = "Nome fantasia deve ter no máximo 255 caracteres")
        String tradeName,

        @Schema(description = "CNPJ com ou sem máscara", example = "12.345.678/0001-95")
        @NotBlank(message = "CNPJ é obrigatório")
        @ValidCnpj
        String cnpj,

        @Schema(description = "Situação cadastral (soft delete via inativação)", example = "true")
        @NotNull(message = "Situação é obrigatória")
        Boolean active
) {
}
