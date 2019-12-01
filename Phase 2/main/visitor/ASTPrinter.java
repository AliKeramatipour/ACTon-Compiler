package main.visitor;

import main.ast.node.Main;
import main.ast.node.Program;
import main.ast.node.declaration.ActorDeclaration;
import main.ast.node.declaration.ActorInstantiation;
import main.ast.node.declaration.VarDeclaration;
import main.ast.node.declaration.handler.HandlerDeclaration;
import main.ast.node.expression.*;
import main.ast.node.expression.values.BooleanValue;
import main.ast.node.expression.values.IntValue;
import main.ast.node.expression.values.StringValue;
import main.ast.node.statement.*;

import java.util.ArrayList;

public class ASTPrinter implements Visitor {

    @Override
    public void visit(Program program) {
        System.out.println(program.toString());

        ArrayList<ActorDeclaration> actors = program.getActors();
        if(actors != null) {
            for(ActorDeclaration actor: actors) {
                actor.accept(this);
            }
        }

        Main main = program.getMain();
        if(main != null) {
            main.accept(this);
        }
    }

    @Override
    public void visit(ActorDeclaration actorDeclaration) {
        System.out.println(actorDeclaration.toString());

        Identifier name = actorDeclaration.getName()
        if(name != null) {
            name.accept(this);
        }

        Identifier parentName = actorDeclaration.getParentName();
        if(parentName != null) {
            parentName = parentName.getName();
            if(parentName != null) {
                parentName.accept(this);
            }
        }

        ArrayList<VarDeclaration> varDecs = actorDeclaration.getKnownActors();
        if(varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                varDec.accept(this);
            }
        }

        varDecs = actorDeclaration.getActorVars();
        if(varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                varDec.accept(this);
            }
        }

        InitHandlerDeclaration initHandlerDeclaration = actorDeclaration.getInitHandler();
        if(initHandlerDeclaration != null){
            initHandlerDeclaration.accept(this);
        }

        ArrayList<MsgHandlerDeclaration> msgHandlerDecs = actorDeclaration.getMsgHandlers();
        if(msgHandlerDecs != null) {
            for (MsgHandlerDeclaration msgHandlerDec : msgHandlerDecs) {
                varDec.accept(this);
            }
        }
    }

    @Override
    public void visit(HandlerDeclaration handlerDeclaration) {
        System.out.println(handlerDeclaration.toString());

        Identifier name = handlerDeclaration.getName()
        if(name != null) {
            name.accept(this);
        }

        ArrayList<VarDeclaration> varDecs = actorDeclaration.getArgs();
        if(varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                varDec.accept(this);
            }
        }

        varDecs = actorDeclaration.getLocalVars();
        if(varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                varDec.accept(this);
            }
        }

        ArrayList<Statement> stmts = actorDeclaration.getBody();
        if(stmts != null) {
            for (Statement stmt : stmts) {
                stmt.accept(this);
            }
        }
    }

    @Override
    public void visit(VarDeclaration varDeclaration) {
        System.out.println(varDeclaration.toString());
    }

    @Override
    public void visit(Main mainActors) {
        System.out.println(mainActors.toString());
    }

    @Override
    public void visit(ActorInstantiation actorInstantiation) {
        System.out.println(actorInstantiation.toString());
    }

    @Override
    public void visit(UnaryExpression unaryExpression) {
        System.out.println(unaryExpression.toString());
    }

    @Override
    public void visit(BinaryExpression binaryExpression) {
        System.out.println(binaryExpression.toString());
    }

    @Override
    public void visit(ArrayCall arrayCall) {
        System.out.println(arrayCall.toString());
    }

    @Override
    public void visit(ActorVarAccess actorVarAccess) {
        System.out.println(actorVarAccess.toString());
    }

    @Override
    public void visit(Identifier identifier) {
        System.out.println(identifier.toString());
    }

    @Override
    public void visit(Self self) {
        System.out.println(self.toString());
    }

    @Override
    public void visit(Sender sender) {
        System.out.println(sender.toString());
    }

    @Override
    public void visit(BooleanValue value) {
        System.out.println(value.toString());
    }

    @Override
    public void visit(IntValue value) {
        System.out.println(value.toString());
    }

    @Override
    public void visit(StringValue value) {
        System.out.println(value.toString());
    }

    @Override
    public void visit(Block block) {
        System.out.println(block.toString());
    }

    @Override
    public void visit(Conditional conditional) {
        System.out.println(conditional.toString());
    }

    @Override
    public void visit(For loop) {
        System.out.println(loop.toString());
    }

    @Override
    public void visit(Break breakLoop) {
        System.out.println(breakLoop.toString());
    }

    @Override
    public void visit(Continue continueLoop) {
        System.out.println(continueLoop.toString());
    }

    @Override
    public void visit(MsgHandlerCall msgHandlerCall) {
        System.out.println(msgHandlerCall.toString());
    }

    @Override
    public void visit(Print print) {
        System.out.println(print.toString());
    }

    @Override
    public void visit(Assign assign) {
        System.out.println(assign.toString());
    }
}
