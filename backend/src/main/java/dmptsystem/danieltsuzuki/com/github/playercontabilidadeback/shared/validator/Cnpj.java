package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.validator;

public final class Cnpj {

    private Cnpj() {
    }

    public static String normalize(String raw) {
        return raw == null ? null : raw.replaceAll("\\D", "");
    }

    public static boolean isValid(String raw) {
        String normalized = normalize(raw);
        if (normalized == null || !normalized.matches("\\d{14}")) {
            return false;
        }
        if (normalized.chars().distinct().count() == 1) {
            return false;
        }
        return check(normalized, 12) == normalized.charAt(12) - '0'
                && check(normalized, 13) == normalized.charAt(13) - '0';
    }

    private static int check(String c, int len) {
        int sum = 0;
        int weight = 2;
        for (int i = len - 1; i >= 0; i--) {
            sum += (c.charAt(i) - '0') * weight;
            weight = (weight == 9) ? 2 : weight + 1;
        }
        int r = sum % 11;
        return r < 2 ? 0 : 11 - r;
    }
}

