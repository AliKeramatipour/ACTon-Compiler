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

import main.ast.type.arrayType.ArrayType;
import main.symbolTable.SymbolTable;
import main.symbolTable.SymbolTableActorItem;
import main.symbolTable.SymbolTableHandlerItem;
import main.symbolTable.SymbolTableMainItem;
import main.symbolTable.itemException.ItemAlreadyExistsException;
import main.symbolTable.symbolTableVariableItem.SymbolTableActorVariableItem;

import java.util.ArrayList;

public class NameAnalyser implements Visitor {

    @Override
    public void visit(Program program) {
        SymbolTable.root = new SymbolTable();

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
        SymbolTable.push(new SymbolTable(SymbolTable.top, actorDeclaration.getName().getName()));

        if (actorDeclaration.getQueueSize() < 1) {
            System.out.println("Line:" + actorDeclaration.getLine() + ":Queue size must be positive " + actorDeclaration.getName().getName());
        }

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

        SymbolTableActorItem actorItem = new SymbolTableActorItem(actorDeclaration);
        actorItem.setActorSymbolTable(SymbolTable.top);
        SymbolTable.pop();

        try {
            SymbolTable.root.put(actorItem);
        } catch (ItemAlreadyExistsException e) {
            System.out.println("Line:" + actorDeclaration.getLine() + ":Redefinition of actor " + actorDeclaration.getName().getName());
        }

        return;
    }

    @Override
    public void visit(HandlerDeclaration handlerDeclaration) {
        SymbolTable.push(new SymbolTable(SymbolTable.top, handlerDeclaration.getName().getName()));

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

        SymbolTableHandlerItem handlerItem = new SymbolTableHandlerItem(handlerDeclaration);
        handlerItem.setHandlerSymbolTable(SymbolTable.top);
        SymbolTable.pop();

        try {
            SymbolTable.top.put(handlerItem);
        } catch (ItemAlreadyExistsException e) {
            System.out.println("Line:" + handlerDeclaration.getLine() + ":Redefinition of msghandler " + handlerDeclaration.getName().getName());
        }

        return;
    }

    @Override
    public void visit(VarDeclaration varDeclaration) {
        if (varDeclaration.isArrayDeclaration()) {
            if (((ArrayType) varDeclaration.getType()).getSize() < 1) {
                System.out.println("Line:" + varDeclaration.getLine() + ":Array size must be positive " + varDeclaration.getIdentifier().getName());
            }
        }

        Identifier id = varDeclaration.getIdentifier();
        if(id != null) {
            id.accept(this);
        }

        try {
            SymbolTable.top.put(new SymbolTableActorVariableItem(varDeclaration));
        } catch (ItemAlreadyExistsException e) {
            System.out.println("Line:" + varDeclaration.getLine() + ":Redefinition of variable " + varDeclaration.getIdentifier().getName());
        }

        return;
    }

    @Override
    public void visit(Main mainActors) {
        SymbolTable.push(new SymbolTable(SymbolTable.top, mainActors.toString()));

        ArrayList<ActorInstantiation> actors = mainActors.getMainActors();
        if(actors != null) {
            for (ActorInstantiation actor : actors) {
                actor.accept(this);
            }
        }

        SymbolTableMainItem mainItem = new SymbolTableMainItem(mainActors);
        mainItem.setMainSymbolTable(SymbolTable.top);
        SymbolTable.pop();

        try {
            SymbolTable.root.put(mainItem);
        } catch (ItemAlreadyExistsException e) {
        }

        return;
    }

    @Override
    public void visit(ActorInstantiation actorInstantiation) {

        try {
            SymbolTable.top.put(new SymbolTableActorVariableItem(actorInstantiation));
        } catch (ItemAlreadyExistsException e) {
            System.out.println("Line:" + actorInstantiation.getLine() + ":Redefinition of variable " + actorInstantiation.getIdentifier().getName());
        }

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

        Expression operand = unaryExpression.getOperand();
        if(operand != null) {
            operand.accept(this);
        }

        return;
    }

    @Override
    public void visit(BinaryExpression binaryExpression) {

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

        Self self = actorVarAccess.getSelf();
        if(self != null) {
            self.accept(this);
        }

        Identifier varName = actorVarAccess.getVariable();
        if(varName != null) {
            varName.accept(this);
        }

        return;
    }

    @Override
    public void visit(Identifier identifier) {

        return;
    }

    @Override
    public void visit(Self self) {

        return;
    }

    @Override
    public void visit(Sender sender) {

        return;
    }

    @Override
    public void visit(BooleanValue value) {

        return;
    }

    @Override
    public void visit(IntValue value) {

        return;
    }

    @Override
    public void visit(StringValue value) {

        return;
    }

    @Override
    public void visit(Block block) {

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

        return;
    }

    @Override
    public void visit(Continue continueLoop) {

        return;
    }

    @Override
    public void visit(MsgHandlerCall msgHandlerCall) {
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

        Expression arg = print.getArg();
        if(arg != null) {
            arg.accept(this);
        }

        return;
    }

    @Override
    public void visit(Assign assign) {

        Expression lValue = assign.getlValue();
        if(lValue != null){
            lValue.accept(this);
        }

        Expression rValue = assign.getrValue();
        if(rValue != null){
            rValue.accept(this);
        }

        return;
    }
}
