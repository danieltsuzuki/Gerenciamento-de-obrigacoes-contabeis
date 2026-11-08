package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.company.dto;

import dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.validator.ValidCnpj;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record CreateCompanyRequest(
        @NotBlank(message = "Razão social é obrigatória")
        @Size(max = 255, message = "Razão social deve ter no máximo 255 caracteres")
        String legalName,

        @Size(max = 255, message = "Nome fantasia deve ter no máximo 255 caracteres")
        String tradeName,

        @NotBlank(message = "CNPJ é obrigatório")
        @ValidCnpj
        String cnpj,

        Boolean active
) {
}

