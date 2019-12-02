package main.visitor;

import main.ast.node.Main;
import main.ast.node.Program;
import main.ast.node.declaration.ActorDeclaration;
import main.ast.node.declaration.ActorInstantiation;
import main.ast.node.declaration.VarDeclaration;
import main.ast.node.declaration.handler.HandlerDeclaration;
import main.ast.node.declaration.handler.MsgHandlerDeclaration;
import main.ast.node.expression.*;
import main.ast.node.expression.values.BooleanValue;
import main.ast.node.expression.values.IntValue;
import main.ast.node.expression.values.StringValue;
import main.ast.node.statement.*;

import main.compileError.CompileErrors;
import main.symbolTable.*;
import main.symbolTable.itemException.ItemAlreadyExistsException;
import main.symbolTable.symbolTableVariableItem.SymbolTableActorVariableItem;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

public class SecondNameAnalyser implements Visitor {

    @Override
    public void visit(Program program) {
        HashMap<String, SymbolTableItem> items = SymbolTable.root.getSymbolTableItems();
        SymbolTable.unVisitAll();

        ArrayList<ActorDeclaration> actors = program.getActors();
        if (actors != null) {
            for (ActorDeclaration actor : actors) {
                items = SymbolTable.root.getSymbolTableItems();
                HashSet<String> visitedSet = new HashSet<String>();

                String actorName = actor.getName().getName();
                SymbolTableActorItem item = (SymbolTableActorItem) items.get(SymbolTableActorItem.STARTKEY + actorName);
                if (!item.isVisited()) {
                    item.visit();
                    visitedSet.add(item.getKey());
                    String parentName = item.getParentName();
                    while (parentName != null) {
                        SymbolTableActorItem parent = (SymbolTableActorItem) items.get(SymbolTableActorItem.STARTKEY + parentName);
                        if (parent == null) {
                            break;
                        }
                        if (parent.isVisited()) {
                            if (!visitedSet.contains(SymbolTableActorItem.STARTKEY + parentName)) {
                                break;
                            }
                            ActorDeclaration actorDec = parent.getActorDeclaration();
                            CompileErrors.add(actorDec.getLine(), "Cyclic inheritance involving actor " + actorName);
                            break;
                        }
                        parent.visit();
                        visitedSet.add(SymbolTableActorItem.STARTKEY + parentName);
                        parentName = parent.getParentName();
                    }
                }
            }

            for (ActorDeclaration actor : actors) {
                String actorName = actor.getName().getName();
                SymbolTableActorItem item = (SymbolTableActorItem) items.get(SymbolTableActorItem.STARTKEY + actorName);
                item.getActorDeclaration().accept(this);
            }
        }
    }

    @Override
    public void visit(ActorDeclaration actorDeclaration) {
        Identifier parentId = actorDeclaration.getParentName();
        if (parentId == null) {
            return;
        }
        String actorName = actorDeclaration.getName().getName();
        HashMap <String, SymbolTableItem> items = SymbolTable.root.getSymbolTableItems();

        ArrayList<VarDeclaration> varDecs = actorDeclaration.getKnownActors();
        if (varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                SymbolTable.unVisitAll();
                items = SymbolTable.root.getSymbolTableItems();

                String parentName = parentId.getName();
                while (parentName != null) {
                    SymbolTableActorItem parent = (SymbolTableActorItem) items.get(SymbolTableActorItem.STARTKEY + parentName);
                    if (parent == null || parentName.equals(actorName) || parent.isVisited())
                        break;
                    HashMap<String, SymbolTableItem> parentSymbolTable = parent.getActorSymbolTable().getSymbolTableItems();
                    String varName = varDec.getIdentifier().getName();
                    if (parentSymbolTable.get(SymbolTableActorVariableItem.STARTKEY + varName) != null) {
                        CompileErrors.add(varDec.getLine(), "Redefinition of variable " + varName);
                        break;
                    }
                    parent.visit();
                    parentName = parent.getParentName();
                }
            }
        }

        varDecs = actorDeclaration.getActorVars();
        if (varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                SymbolTable.unVisitAll();
                items = SymbolTable.root.getSymbolTableItems();

                String parentName = parentId.getName();
                while (parentName != null) {
                    SymbolTableActorItem parent = (SymbolTableActorItem) items.get(SymbolTableActorItem.STARTKEY + parentName);
                    if (parent == null || parentName.equals(actorName) || parent.isVisited())
                        break;
                    HashMap<String, SymbolTableItem> parentSymbolTable = parent.getActorSymbolTable().getSymbolTableItems();
                    String varName = varDec.getIdentifier().getName();
                    if (parentSymbolTable.get(SymbolTableActorVariableItem.STARTKEY + varName) != null) {
                        CompileErrors.add(varDec.getLine(), "Redefinition of variable " + varName);
                        break;
                    }
                    parent.visit();
                    parentName = parent.getParentName();
                }
            }
        }

        ArrayList<MsgHandlerDeclaration> msgHandlerDecs = actorDeclaration.getMsgHandlers();
        if (msgHandlerDecs != null) {
            for (MsgHandlerDeclaration msgHandlerDec : msgHandlerDecs) {
                SymbolTable.unVisitAll();
                items = SymbolTable.root.getSymbolTableItems();

                String parentName = parentId.getName();
                while (parentName != null) {
                    SymbolTableActorItem parent = (SymbolTableActorItem) items.get(SymbolTableActorItem.STARTKEY + parentName);
                    if (parent == null || parentName.equals(actorName) || parent.isVisited())
                        break;
                    HashMap<String, SymbolTableItem> parentSymbolTable = parent.getActorSymbolTable().getSymbolTableItems();
                    String handlerName = msgHandlerDec.getName().getName();
                    if (parentSymbolTable.get(SymbolTableHandlerItem.STARTKEY + handlerName) != null) {
                        CompileErrors.add(msgHandlerDec.getLine(), "Redefinition of msghandler " + handlerName);
                        break;
                    }
                    parent.visit();
                    parentName = parent.getParentName();
                }
            }
        }
    }









    @Override
    public void visit(HandlerDeclaration handlerDeclaration) {

        ArrayList<VarDeclaration> varDecs = handlerDeclaration.getArgs();
        if (varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                varDec.accept(this);
            }
        }

        varDecs = handlerDeclaration.getLocalVars();
        if (varDecs != null) {
            for (VarDeclaration varDec : varDecs) {
                varDec.accept(this);
            }
        }

        ArrayList<Statement> stmts = handlerDeclaration.getBody();
        if (stmts != null) {
            for (Statement stmt : stmts) {
                stmt.accept(this);
            }
        }
    }

    @Override
    public void visit(VarDeclaration varDeclaration) {

        Identifier id = varDeclaration.getIdentifier();
        if (id != null) {
            id.accept(this);
        }
    }

    @Override
    public void visit(Main mainActors) {

        ArrayList<ActorInstantiation> actors = mainActors.getMainActors();
        if (actors != null) {
            for (ActorInstantiation actor : actors) {
                actor.accept(this);
            }
        }
    }

    @Override
    public void visit(ActorInstantiation actorInstantiation) {

        Identifier id = actorInstantiation.getIdentifier();
        if (id != null) {
            id.accept(this);
        }

        ArrayList<Identifier> knownActors = actorInstantiation.getKnownActors();
        if (knownActors != null) {
            for (Identifier actor : knownActors) {
                actor.accept(this);
            }
        }

        ArrayList<Expression> initArgs = actorInstantiation.getInitArgs();
        if (initArgs != null) {
            for (Expression arg : initArgs) {
                arg.accept(this);
            }
        }
    }

    @Override
    public void visit(UnaryExpression unaryExpression) {

        Expression operand = unaryExpression.getOperand();
        if (operand != null) {
            operand.accept(this);
        }
    }

    @Override
    public void visit(BinaryExpression binaryExpression) {

        Expression leftOperand = binaryExpression.getLeft();
        if (leftOperand != null) {
            leftOperand.accept(this);
        }

        Expression rightOperand = binaryExpression.getRight();
        if (rightOperand != null) {
            rightOperand.accept(this);
        }

    }

    @Override
    public void visit(ArrayCall arrayCall) {

        Expression arrayInstance = arrayCall.getArrayInstance();
        if (arrayInstance != null) {
            arrayInstance.accept(this);
        }

        Expression index = arrayCall.getIndex();
        if (index != null) {
            index.accept(this);
        }
    }

    @Override
    public void visit(ActorVarAccess actorVarAccess) {

        Self self = actorVarAccess.getSelf();
        if (self != null) {
            self.accept(this);
        }

        Identifier varName = actorVarAccess.getVariable();
        if (varName != null) {
            varName.accept(this);
        }
    }

    @Override
    public void visit(Identifier identifier) {
    }

    @Override
    public void visit(Self self) {
    }

    @Override
    public void visit(Sender sender) {
    }

    @Override
    public void visit(BooleanValue value) {
    }

    @Override
    public void visit(IntValue value) {
    }

    @Override
    public void visit(StringValue value) {
    }

    @Override
    public void visit(Block block) {

        ArrayList<Statement> stmts = block.getStatements();
        if (stmts != null) {
            for (Statement stmt : stmts) {
                stmt.accept(this);
            }
        }
    }

    @Override
    public void visit(Conditional conditional) {

        Expression expr = conditional.getExpression();
        if (expr != null) {
            expr.accept(this);
        }

        Statement thenBody = conditional.getThenBody();
        if (thenBody != null) {
            thenBody.accept(this);
        }

        Statement elseBody = conditional.getElseBody();
        if (elseBody != null) {
            elseBody.accept(this);
        }
    }

    @Override
    public void visit(For loop) {

        Assign initialize = loop.getInitialize();
        if (initialize != null) {
            initialize.accept(this);
        }

        Expression condition = loop.getCondition();
        if (condition != null) {
            condition.accept(this);
        }

        Assign update = loop.getUpdate();
        if (update != null) {
            update.accept(this);
        }

        Statement body = loop.getBody();
        if (body != null) {
            body.accept(this);
        }
    }

    @Override
    public void visit(Break breakLoop) {
    }

    @Override
    public void visit(Continue continueLoop) {
    }

    @Override
    public void visit(MsgHandlerCall msgHandlerCall) {

        Expression instance = msgHandlerCall.getInstance();
        if (instance != null) {
            instance.accept(this);
        }

        Identifier msgHandlerName = msgHandlerCall.getMsgHandlerName();
        if (msgHandlerName != null) {
            msgHandlerName.accept(this);
        }

        ArrayList<Expression> args = msgHandlerCall.getArgs();
        if (args != null) {
            for (Expression arg : args) {
                arg.accept(this);
            }
        }
    }

    @Override
    public void visit(Print print) {

        Expression arg = print.getArg();
        if (arg != null) {
            arg.accept(this);
        }
    }

    @Override
    public void visit(Assign assign) {

        Expression lValue = assign.getlValue();
        if (lValue != null) {
            lValue.accept(this);
        }

        Expression rValue = assign.getrValue();
        if (rValue != null) {
            rValue.accept(this);
        }
    }
}
