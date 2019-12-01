grammar acton;

@header{
    package main.parsers;
    import main.*;
    //    import main.ast.* ;
    import main.ast.node.*;
    import main.ast.node.declaration.*;
    import main.ast.node.declaration.handler.*;
    import main.ast.node.expression.*;
    import main.ast.node.expression.operators.*;
    import main.ast.node.expression.values.*;
    import main.ast.node.statement.*;
    import main.ast.type.*;
    import main.ast.type.actorType.*;
    import main.ast.type.arrayType.*;
    import main.ast.type.primitiveType.*;
    import java.util.ArrayList;
}

program returns [Program p]
    : {$p = new Program();}
    (a = actorDeclaration { $p.addActor($a.actorDec); })+ m = mainDeclaration { $p.setMain(m.main); }
    ;

actorDeclaration returns [ActorDeclaration actorDec]
:
	ACTOR name = identifier {$actorDec = new ActorDeclaration($name.identifier); }
    (EXTENDS parent = identifier { $actorDec.setParent($parent.identifier); })?
    LPAREN INTVAL { $actorDec.setQueueSize($INTVAL.int); } RPAREN
        LBRACE

        (KNOWNACTORS
        LBRACE
	    (
            actorType = identifier actorName = identifier SEMICOLON
            {
                $actorDec.addKnownActor(
                    new VarDeclaration(
                        new Identifier($actorName.text),
                        new ActorType($actorType.text)
                    )
                );
            }
        )*
        RBRACE)

        (ACTORVARS
        LBRACE
            varDeclarations { $actorDec.setActorVars($varDeclarations.varDecs); }
        RBRACE)

        (initHandlerDeclaration)?
        (msgHandlerDeclaration)*

        RBRACE
    ;

mainDeclaration returns [Main main]
    :   MAIN
    	LBRACE
        actorInstantiation*
    	RBRACE
    ;

actorInstantiation
    :	identifier identifier
     	LPAREN (identifier(COMMA identifier)* | ) RPAREN
     	COLON LPAREN expressionList RPAREN SEMICOLON
    ;

initHandlerDeclaration
	returns [InitHandlerDeclaration initHandlerDec]
    :
	    MSGHANDLER INITIAL
        { $initHandlerDec = new InitHandlerDeclaration($INITIAL.text); }
        LPAREN
            argDeclarations
            { $initHandlerDec.setArgs($argDeclarations.args); }
        RPAREN
     	LBRACE
        varDeclarations { $initHandlerDec.setLocalVars($varDeclarations.varDecs); }
        (statement { $initHandlerDec.addStatement($statement.stmt); })*
     	RBRACE
    ;

msgHandlerDeclaration
    :	MSGHANDLER identifier LPAREN argDeclarations RPAREN
       	LBRACE
       	varDeclarations
       	(statement)*
       	RBRACE
    ;

argDeclarations
	returns [ArrayList<VarDeclaration> args]
    :
        { $args = new ArrayList<>(); }
        varDeclaration { $args.add($varDeclaration.varDec); }
        (COMMA varDeclaration { $args.add($varDeclaration.varDec); })* |
    ;

varDeclarations returns [ArrayList<VarDeclaration> varDecs]
    :
	{ $varDecs = new ArrayList<>(); }
    (varDeclaration SEMICOLON { $varDecs.add($varDeclaration.varDec); } )*
    ;

varDeclaration returns [VarDeclaration varDec] locals [Type t, Identifier id]
:
	(INT identifier { $t = new IntType(); $id = $identifier.identifier }
    | STRING identifier { $t = new StringType(); $id = $identifier.identifier }
    | BOOLEAN identifier { $t = new BooleanType(); $id = $identifier.identifier }
    | INT identifier LBRACKET INTVAL RBRACKET { $t = new ArrayType(); $t.setSize($INTVAL.int); $id = $identifier.identifier })
    {$varDec = new VarDeclaration($id, $t);}
    ;

statement
	returns [Statement stmt]
    :	blockStmt       { $stmt = $blockStmt.stmt; }
    | 	printStmt       { $stmt = $printStmt.stmt; }
    |  	assignStmt      { $stmt = $assignStmt.stmt; }
    |  	forStmt         { $stmt = $forStmt.stmt; }
    |  	ifStmt          { $stmt = $ifStmt.stmt; }
    |  	continueStmt    { $stmt = $continueStmt.stmt; }
    |  	breakStmt       { $stmt = $breakStmt.stmt; }
    |  	msgHandlerCall  { $stmt = $msgHandlerCall.stmt; }
    ;

blockStmt returns [Block stmt]
    : { $stmt = new Block(); }
    LBRACE
        (statement { $stmt.addStatement($statement.statement); })*
    RBRACE
    ;

//CHECK THIS PART
printStmt returns [Print stmt]
    :
	PRINT LPAREN expression RPAREN SEMICOLON { $stmt = new Print($expression.exp); }
    ;

assignStmt returns [Assign stmt]
    : assignment SEMICOLON {$stmt = $assignment.stmt}
    ;

assignment returns [Assign stmt]
    :
	orExpression ASSIGN expression { $stmt = new Assign($orExpression.exp, $expression.exp); }
    ;

forStmt returns [For stmt]
    :
        { $stmt = new For(); }
        FOR LPAREN
            (assignment { $stmt.setInitialize($assignment.stmt); })?
        SEMICOLON
            (expression { $stmt.setCondition($expression.stmt); })?
        SEMICOLON
            (assignment { $stmt.setUpdate($assignment.stmt); })?
        RPAREN
            statement   { $stmt.setBody($statement.stmt); }
    ;

ifStmt
	returns [Conditional stmt]
    :   IF LPAREN expression RPAREN statement elseStmt
        {
            $stmt = new Conditional($expression.exp, $statement.stmt);
		    if ($elseStmt.stmt != null)
		        $stmt.setElseBody($elseStmt.stmt);
        }
    ;

elseStmt
	returns [Statement stmt]
    : ELSE statement { $stmt = $statement.stmt; } |
    ;

continueStmt
	returns[Continue stmt]
    : 	CONTINUE SEMICOLON
    { $stmt = new Continue(); }
    ;

breakStmt
	returns [Break stmt]
    : 	BREAK SEMICOLON
    { $stmt = new Break(); }
    ;

msgHandlerCall
	returns[MsgHandlerCall stmt]
	locals[Expression instance]
    :
    (
        identifier { $instance = $identifier.identifier; }
        | SELF { $instance = new Self(); }
        | SENDER { $instance = new Sender(); }
    ) DOT
        identifier { $stmt = new MsgHandlerCall($instance, $identifier.identifier); }
        LPAREN
            expressionList { $stmt.setArgs($expressionList.exps); }
        RPAREN
    SEMICOLON
    ;

expression returns [Expression exp]
    :	orExpression (ASSIGN expression)?
    ;

orExpression
    :	andExpression (OR andExpression)*
    ;

andExpression
    :	equalityExpression (AND equalityExpression)*
    ;

equalityExpression
    :	relationalExpression ( (EQ | NEQ) relationalExpression)*
    ;

relationalExpression
    : additiveExpression ((LT | GT) additiveExpression)*
    ;

additiveExpression
    : multiplicativeExpression ((PLUS | MINUS) multiplicativeExpression)*
    ;

multiplicativeExpression
    : preUnaryExpression ((MULT | DIV | PERCENT) preUnaryExpression)*
    ;

preUnaryExpression
    :   NOT preUnaryExpression
    |   MINUS preUnaryExpression
    |   PLUSPLUS preUnaryExpression
    |   MINUSMINUS preUnaryExpression
    |   postUnaryExpression
    ;

postUnaryExpression
    :   otherExpression (postUnaryOp)?
    ;

postUnaryOp
    :	PLUSPLUS | MINUSMINUS
    ;

otherExpression
    :    LPAREN expression RPAREN
    |    identifier
    |    arrayCall
    |    actorVarAccess
    |    value
    |    SENDER
    ;

arrayCall
    :   (identifier | actorVarAccess) LBRACKET expression RBRACKET
    ;

actorVarAccess
    :   SELF DOT identifier
    ;

expressionList
	returns[ArrayList<Expression> exps]
    :
        { $exps = new ArrayList<>(); }
        expression { $exps.add($expression.exp); }
        (COMMA expression { $exps.add($expression.exp); })* |

    ;

identifier returns [Identifier identifier]
    : IDENTIFIER {$identifier = new Identifier($IDENTIFIER.text); }
    ;

value returns [Value val]
    :
	INTVAL { $val = new IntValue($INTVAL.int, new IntType()); }
    | STRINGVAL { $val = new StringValue($STRINGVAL.text, new StringType()); }
    | TRUE { $val = new BooleanValue(true, new BooleanType()); }
    | FALSE { $val = new BooleanValue(false, new BooleanType()); }
    ;

// values
INTVAL
    : [1-9][0-9]* | [0]
    ;

STRINGVAL
    : '"'~["]*'"'
    ;

TRUE
    :   'true'
    ;

FALSE
    :   'false'
    ;

//types
INT
    : 'int'
    ;

BOOLEAN
    : 'boolean'
    ;

STRING
    : 'string'
    ;

//keywords
ACTOR
	:	'actor'
	;

EXTENDS
	:	'extends'
	;

ACTORVARS
	:	'actorvars'
	;

KNOWNACTORS
	:	'knownactors'
	;

INITIAL
    :   'initial'
    ;

MSGHANDLER
	: 	'msghandler'
	;

SENDER
    :   'sender'
    ;

SELF
    :   'self'
    ;

MAIN
	:	'main'
	;

FOR
    :   'for'
    ;

CONTINUE
    :   'continue'
    ;

BREAK
    :   'break'
    ;

IF
    :   'if'
    ;

ELSE
    :   'else'
    ;

PRINT
    :   'print'
    ;

//symbols
LPAREN
    :   '('
    ;

RPAREN
    :   ')'
    ;

LBRACE
    :   '{'
    ;

RBRACE
    :   '}'
    ;

LBRACKET
    :   '['
    ;

RBRACKET
    :   ']'
    ;

COLON
    :   ':'
    ;

SEMICOLON
    :   ';'
    ;

COMMA
    :   ','
    ;

DOT
    :   '.'
    ;

//operators
ASSIGN
    :   '='
    ;

EQ
    :   '=='
    ;

NEQ
    :   '!='
    ;

GT
    :   '>'
    ;

LT
    :   '<'
    ;

PLUSPLUS
    :   '++'
    ;

MINUSMINUS
    :   '--'
    ;

PLUS
    :   '+'
    ;

MINUS
    :   '-'
    ;

MULT
    :   '*'
    ;

DIV
    :   '/'
    ;

PERCENT
    :   '%'
    ;

NOT
    :   '!'
    ;

AND
    :   '&&'
    ;

OR
    :   '||'
    ;

QUES
    :   '?'
    ;

IDENTIFIER
    :   [a-zA-Z_][a-zA-Z0-9_]*
    ;

COMMENT
    :   '//' ~[\n\r]* -> skip
    ;

WHITESPACE
    :   [ \t\r\n] -> skip
    ;
