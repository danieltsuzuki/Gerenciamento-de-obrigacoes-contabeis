package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.validator;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import static org.assertj.core.api.Assertions.assertThat;

class CnpjTest {

    @ParameterizedTest
    @ValueSource(strings = {
            "00000000000191",
            "00.000.000/0001-91",
            "33000167000101",
            "33.000.167/0001-01",
            "07526557000100",
            "07.526.557/0001-00",
            "12ABC34501DE35",
            "12.ABC.345/01DE-35",
            "AB123456000110",
            "AB.123.456/0001-10"
    })
    @DisplayName("deve aceitar CNPJ válido formatado ou desformatado (numérico e alfanumérico)")
    void shouldAcceptValidCnpj(String cnpj) {
        assertThat(Cnpj.isValid(cnpj)).isTrue();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "00000000000000",
            "11111111111111",
            "22222222222222",
            "33333333333333",
            "44444444444444",
            "55555555555555",
            "66666666666666",
            "77777777777777",
            "88888888888888",
            "99999999999999"
    })
    @DisplayName("deve rejeitar CNPJ com todos os dígitos iguais")
    void shouldRejectRepeatedDigits(String cnpj) {
        assertThat(Cnpj.isValid(cnpj)).isFalse();
    }

    @ParameterizedTest
    @ValueSource(strings = {
            "00000000000192", // DV incorreto
            "33000167000109", // DV incorreto
            "12345678901234",
            "123",            // tamanho insuficiente
            "123456780001999",// tamanho excessivo
            "",
            "   ",
            "abcdefghijklmn"
    })
    @DisplayName("deve rejeitar CNPJs inválidos por dígitos verificadores ou formato")
    void shouldRejectInvalidCnpj(String cnpj) {
        assertThat(Cnpj.isValid(cnpj)).isFalse();
    }

    @Test
    @DisplayName("deve rejeitar nulo")
    void shouldRejectNull() {
        assertThat(Cnpj.isValid(null)).isFalse();
    }

    @Test
    @DisplayName("normalize deve remover caracteres de formatação e manter alfanuméricos em maiúsculas")
    void shouldNormalizeCnpj() {
        assertThat(Cnpj.normalize("33.000.167/0001-01")).isEqualTo("33000167000101");
        assertThat(Cnpj.normalize("33000167000101")).isEqualTo("33000167000101");
        assertThat(Cnpj.normalize("12.abc.345/01de-35")).isEqualTo("12ABC34501DE35");
        assertThat(Cnpj.normalize(null)).isNull();
    }
}

