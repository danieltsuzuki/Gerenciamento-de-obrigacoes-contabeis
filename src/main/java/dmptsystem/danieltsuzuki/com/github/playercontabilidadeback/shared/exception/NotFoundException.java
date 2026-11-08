package dmptsystem.danieltsuzuki.com.github.playercontabilidadeback.shared.exception;

public class NotFoundException extends RuntimeException {

    private final String resource;
    private final Object identifier;

    public NotFoundException(String resource, Object identifier) {
        super(resource + " não encontrada(o) com identificador: " + identifier);
        this.resource = resource;
        this.identifier = identifier;
    }

    public String getResource() {
        return resource;
    }

    public Object getIdentifier() {
        return identifier;
    }
}

