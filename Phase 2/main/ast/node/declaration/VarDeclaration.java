package main.ast.node.declaration;

import main.ast.type.Type;
import main.ast.type.arrayType.ArrayType;
import main.visitor.Visitor;
import main.ast.node.expression.Identifier;

public class VarDeclaration extends Declaration {
    private Identifier identifier;
    private Type type;

    public VarDeclaration(Identifier identifier, Type type) {
        this.identifier = identifier;
        this.type = type;
    }

    public Identifier getIdentifier() {
        return identifier;
    }

    public void setIdentifier(Identifier identifier) {
        this.identifier = identifier;
    }

    public Type getType() {
        return type;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public boolean isArrayDeclaration() {
        return this.type instanceof ArrayType;
    }

    @Override
    public String toString() {
        return "VarDeclaration";
    }

    public void accept(Visitor visitor) {
        visitor.visit(this);
    }
}