package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.validator.ValidCnpj;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Schema(description = "Dados para cadastro de nova empresa")
public record CreateCompanyRequest(
        @Schema(description = "Razão social da empresa", example = "Alpha Contabilidade Ltda")
        @NotBlank(message = "Razão social é obrigatória")
        @Size(max = 255, message = "Razão social deve ter no máximo 255 caracteres")
        String legalName,

        @Schema(description = "Nome fantasia", example = "Alpha Tech")
        @Size(max = 255, message = "Nome fantasia deve ter no máximo 255 caracteres")
        String tradeName,

        @Schema(description = "CNPJ com ou sem máscara (validado com dígitos verificadores)", example = "12.345.678/0001-95")
        @NotBlank(message = "CNPJ é obrigatório")
        @ValidCnpj
        String cnpj,

        @Schema(description = "Indica se a empresa já inicia ativa (padrão true)", example = "true")
        Boolean active
) {
}
