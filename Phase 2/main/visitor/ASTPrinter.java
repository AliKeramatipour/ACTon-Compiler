package main.visitor;

import main.ast.node.Main;
import main.ast.node.Program;
import main.ast.node.declaration.ActorDeclaration;
import main.ast.node.declaration.ActorInstantiation;
import main.ast.node.declaration.VarDeclaration;
import main.ast.node.declaration.handler.HandlerDeclaration;
import main.ast.node.declaration.handler.InitHandlerDeclaration;
import main.ast.node.declaration.handler.MsgHandlerDeclaration;
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

        return;
    }

    @Override
    public void visit(ActorDeclaration actorDeclaration) {
        System.out.println(actorDeclaration.toString());

        Identifier name = actorDeclaration.getName();
        if(name != null) {
            name.accept(this);
        }

        Identifier parentName = actorDeclaration.getParentName();
        if(parentName != null) {
            parentName.accept(this);
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
                msgHandlerDec.accept(this);
            }
        }

        return;
    }

    @Override
    public void visit(HandlerDeclaration handlerDeclaration) {
        System.out.println(handlerDeclaration.toString());

        Identifier name = handlerDeclaration.getName();
        if(name != null) {
            name.accept(this);
        }

        ArrayList<VarDeclaration> varDecs = handlerDeclaration.getArgs();
        if(varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                varDec.accept(this);
            }
        }

        varDecs = handlerDeclaration.getLocalVars();
        if(varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                varDec.accept(this);
            }
        }

        ArrayList<Statement> stmts = handlerDeclaration.getBody();
        if(stmts != null) {
            for (Statement stmt : stmts) {
                stmt.accept(this);
            }
        }

        return;
    }

    @Override
    public void visit(VarDeclaration varDeclaration) {
        System.out.println(varDeclaration.toString());

        Identifier id = varDeclaration.getIdentifier();
        if(id != null) {
            id.accept(this);
        }

        return;
    }

    @Override
    public void visit(Main mainActors) {
        System.out.println(mainActors.toString());

        ArrayList<ActorInstantiation> actors = mainActors.getMainActors();
        if(actors != null) {
            for (ActorInstantiation actor : actors) {
                actor.accept(this);
            }
        }

        return;
    }

    @Override
    public void visit(ActorInstantiation actorInstantiation) {
        System.out.println(actorInstantiation.toString());

        Identifier id = actorInstantiation.getIdentifier();
        if(id != null) {
            id.accept(this);
        }

        ArrayList<Identifier> knownActors = actorInstantiation.getKnownActors();
        if(knownActors != null) {
            for (Identifier actor : knownActors) {
                actor.accept(this);
            }
        }

        ArrayList<Expression> initArgs = actorInstantiation.getInitArgs();
        if(initArgs != null) {
            for (Expression arg : initArgs) {
                arg.accept(this);
            }
        }

        return;
    }

    @Override
    public void visit(UnaryExpression unaryExpression) {
        System.out.println(unaryExpression.toString());

        Expression operand = unaryExpression.getOperand();
        if(operand != null) {
            operand.accept(this);
        }

        return;
    }

    @Override
    public void visit(BinaryExpression binaryExpression) {
        System.out.println(binaryExpression.toString());

        Expression leftOperand = binaryExpression.getLeft();
        if(leftOperand != null) {
            leftOperand.accept(this);
        }

        Expression rightOperand = binaryExpression.getRight();
        if(rightOperand != null) {
            rightOperand.accept(this);
        }

        return;
    }

    @Override
    public void visit(ArrayCall arrayCall) {
        System.out.println(arrayCall.toString());

        Expression arrayInstance = arrayCall.getArrayInstance();
        if(arrayInstance != null) {
            arrayInstance.accept(this);
        }

        Expression index = arrayCall.getIndex();
        if(index != null) {
            index.accept(this);
        }

        return;
    }

    @Override
    public void visit(ActorVarAccess actorVarAccess) {
        System.out.println(actorVarAccess.toString());

        Identifier varName = actorVarAccess.getVariable();
        if(varName != null) {
            varName.accept(this);
        }

        Self self = actorVarAccess.getSelf();
        if(self != null) {
            self.accept(this);
        }

        return;
    }

    @Override
    public void visit(Identifier identifier) {
        System.out.println(identifier.toString());

        return;
    }

    @Override
    public void visit(Self self) {
        System.out.println(self.toString());

        return;
    }

    @Override
    public void visit(Sender sender) {
        System.out.println(sender.toString());

        return;
    }

    @Override
    public void visit(BooleanValue value) {
        System.out.println(value.toString());

        return;
    }

    @Override
    public void visit(IntValue value) {
        System.out.println(value.toString());

        return;
    }

    @Override
    public void visit(StringValue value) {
        System.out.println(value.toString());

        return;
    }

    @Override
    public void visit(Block block) {
        System.out.println(block.toString());

        ArrayList<Statement> stmts = block.getStatements();
        if(stmts != null) {
            for(Statement stmt : stmts) {
                stmt.accept(this);
            }
        }

        return;
    }

    @Override
    public void visit(Conditional conditional) {
        System.out.println(conditional.toString());

        Expression expr = conditional.getExpression();
        if(expr != null) {
            expr.accept(this);
        }

        Statement thenBody = conditional.getThenBody();
        if(thenBody != null) {
            thenBody.accept(this);
        }

        Statement elseBody = conditional.getElseBody();
        if(elseBody != null) {
            elseBody.accept(this);
        }

        return;
    }

    @Override
    public void visit(For loop) {
        System.out.println(loop.toString());

        Assign initialize = loop.getInitialize();
        if(initialize != null) {
            initialize.accept(this);
        }

        Expression condition = loop.getCondition();
        if(condition != null) {
            condition.accept(this);
        }

        Assign update = loop.getUpdate();
        if(update != null) {
            update.accept(this);
        }

        Statement body = loop.getBody();
        if(body != null) {
            body.accept(this);
        }


        return;
    }

    @Override
    public void visit(Break breakLoop) {
        System.out.println(breakLoop.toString());

        return;
    }

    @Override
    public void visit(Continue continueLoop) {
        System.out.println(continueLoop.toString());

        return;
    }

    @Override
    public void visit(MsgHandlerCall msgHandlerCall) {
        System.out.println(msgHandlerCall.toString());
        Expression instance = msgHandlerCall.getInstance();
        if(instance != null) {
            instance.accept(this);
        }

        Identifier msgHandlerName = msgHandlerCall.getMsgHandlerName();
        if(msgHandlerName != null) {
            msgHandlerName.accept(this);
        }

        ArrayList<Expression> args = msgHandlerCall.getArgs();
        if(args != null) {
            for(Expression arg : args) {
                arg.accept(this);
            }
        }

        return;
    }

    @Override
    public void visit(Print print) {
        System.out.println(print.toString());

        Expression arg = print.getArg();
        if(arg != null) {
            arg.accept(this);
        }

        return;
    }

    @Override
    public void visit(Assign assign) {
        System.out.println(assign.toString());

        Expression lValue = assign.getlValue();
        if(lValue != null){
            lValue.accept(null);
        }

        Expression rValue = assign.getrValue();
        if(rValue != null){
            rValue.accept(null);
        }

        return;
    }
}
