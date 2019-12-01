grammar acton;

@header{
    package main.parsers;
    import main.*;
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
    : { $p = new Program(); }
    (actorDeclaration { $p.addActor($actorDeclaration.actorDec); })+
    mainDeclaration { $p.setMain($mainDeclaration.main); }
    ;

actorDeclaration
	returns[ActorDeclaration actorDec]
	locals[VarDeclaration varDec]
:
	ACTOR name = identifier {$actorDec = new ActorDeclaration($name.id); $actorDec.setLine($ACTOR.getLine()); }
    (EXTENDS parent = identifier { $actorDec.setParentName($parent.id); })?
    LPAREN INTVAL { $actorDec.setQueueSize($INTVAL.int); } RPAREN
        LBRACE

        (KNOWNACTORS
        LBRACE
	    (
            actorType = identifier actorName = identifier SEMICOLON
            {
                $varDec = new VarDeclaration(
                    new Identifier($actorName.text),
                    new ActorType($actorType.id)
                );
		        $varDec.setLine($actorType.id.getLine());
                $actorDec.addKnownActor($varDec);
            }
        )*
        RBRACE)

        (ACTORVARS
        LBRACE
            varDeclarations { $actorDec.setActorVars($varDeclarations.varDecs); }
        RBRACE)

        (initHandlerDeclaration { $actorDec.setInitHandler($initHandlerDeclaration.handlerDec); } )?
        (msgHandlerDeclaration { $actorDec.addMsgHandler($msgHandlerDeclaration.handlerDec); })*

        RBRACE
    ;

mainDeclaration returns [Main main]
    :   { $main = new Main(); }
        MAIN { $main.setLine($MAIN.getLine()); }
    	LBRACE
        (
            actorInstantiation
            { $main.addActorInstantiation($actorInstantiation.actorInstance); }
        )*
    	RBRACE
    ;

actorInstantiation
	returns [ActorInstantiation actorInstance]
    :	actorType = identifier actorName = identifier
        {
            $actorInstance = new ActorInstantiation(
                new ActorType($actorType.id),
                $actorName.id
            );
	        $actorInstance.setLine($actorType.id.getLine());
        }
     	LPAREN
        (
	        identifier { $actorInstance.addKnownActor($identifier.id); }
            (COMMA identifier { $actorInstance.addKnownActor($identifier.id); })*
            |
        )
        RPAREN
     	COLON
        LPAREN
            expressionList { $actorInstance.setInitArgs($expressionList.exps); }
        RPAREN SEMICOLON
    ;

initHandlerDeclaration
	returns [InitHandlerDeclaration handlerDec]
    :
	    MSGHANDLER INITIAL
        {
            $handlerDec = new InitHandlerDeclaration(new Identifier($INITIAL.text));
		    $handlerDec.setLine($MSGHANDLER.getLine());
        }
        LPAREN
            argDeclarations
            { $handlerDec.setArgs($argDeclarations.args); }
        RPAREN
     	LBRACE
            varDeclarations { $handlerDec.setLocalVars($varDeclarations.varDecs); }
            (statement { $handlerDec.addStatement($statement.stmt); })*
     	RBRACE
    ;

msgHandlerDeclaration
	returns [MsgHandlerDeclaration handlerDec]
    :
        MSGHANDLER identifier
            {
                $handlerDec = new MsgHandlerDeclaration($identifier.id);
	            $handlerDec.setLine($MSGHANDLER.getLine());
            }
        LPAREN
            argDeclarations
            {
                $handlerDec.setArgs($argDeclarations.args);
            }
        RPAREN
       	LBRACE
            varDeclarations { $handlerDec.setLocalVars($varDeclarations.varDecs); }
            (statement { $handlerDec.addStatement($statement.stmt); })*
       	RBRACE
    ;

argDeclarations
	returns [ArrayList<VarDeclaration> args]
    :
        { $args = new ArrayList<VarDeclaration>(); }
        (varDeclaration { $args.add($varDeclaration.varDec); }
        (COMMA varDeclaration { $args.add($varDeclaration.varDec); })* |)
    ;

varDeclarations returns [ArrayList<VarDeclaration> varDecs]
    :
	{ $varDecs = new ArrayList<VarDeclaration>(); }
    (varDeclaration SEMICOLON { $varDecs.add($varDeclaration.varDec); } )*
    ;

varDeclaration returns [VarDeclaration varDec] locals [Type t, Identifier id]
:
	(INT identifier { $t = new IntType(); $t.setLine($INT.getLine()); $id = $identifier.id; }
    | STRING identifier { $t = new StringType(); $t.setLine($STRING.getLine()); $id = $identifier.id; }
    | BOOLEAN identifier { $t = new BooleanType(); $t.setLine($BOOLEAN.getLine()); $id = $identifier.id; }
    | INT identifier LBRACKET INTVAL RBRACKET { $t = new ArrayType($INTVAL.int); $t.setLine($INT.getLine()); $id = $identifier.id; })
    { $varDec = new VarDeclaration($id, $t); $varDec.setLine($t.getLine()); }
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
    LBRACE { $stmt.setLine($LBRACE.getLine()); }
        (statement { $stmt.addStatement($statement.stmt); })*
    RBRACE
    ;

//CHECK THIS PART
printStmt returns [Print stmt]
    :
	PRINT LPAREN expression RPAREN SEMICOLON { $stmt = new Print($expression.exp); $stmt.setLine($PRINT.getLine()); }
    ;

assignStmt returns [Assign stmt]
    : assignment SEMICOLON { $stmt = $assignment.stmt; }
    ;

assignment returns [Assign stmt]
    :
	orExpression ASSIGN expression { $stmt = new Assign($orExpression.exp, $expression.exp); $stmt.setLine($ASSIGN.getLine()); }
    ;

forStmt returns [For stmt]
    :
        FOR { $stmt = new For(); $stmt.setLine($FOR.getLine()); }
        LPAREN
            (assignment { $stmt.setInitialize($assignment.stmt); })?
        SEMICOLON
            (expression { $stmt.setCondition($expression.exp); })?
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
	        $stmt.setLine($IF.getLine());
		    if ($elseStmt.stmt != null)
		        $stmt.setElseBody($elseStmt.stmt);
        }
    ;

elseStmt
	returns [Statement stmt]
    : ELSE statement {
        $stmt = $statement.stmt;
        $stmt.setLine($ELSE.getLine());
    } |
    ;

continueStmt
	returns [Continue stmt]
    : 	CONTINUE SEMICOLON
    {
        $stmt = new Continue();
	    $stmt.setLine($CONTINUE.getLine());
    }
    ;

breakStmt
	returns [Break stmt]
    : 	BREAK SEMICOLON
    {
        $stmt = new Break();
	    $stmt.setLine($BREAK.getLine());
    }
    ;

msgHandlerCall
	returns [MsgHandlerCall stmt]
	locals[Expression instance]
    :
    (
        identifier { $instance = $identifier.id; }
        | SELF { $instance = new Self(); $instance.setLine($SELF.getLine()); }
        | SENDER { $instance = new Sender(); $instance.setLine($SENDER.getLine()); }
    ) DOT
        // TODO: check set line
        identifier { $stmt = new MsgHandlerCall($instance, $identifier.id); $stmt.setLine($instance.getLine()); }
        LPAREN
            expressionList { $stmt.setArgs($expressionList.exps); }
        RPAREN
    SEMICOLON
    ;

expression
    returns [Expression exp]
    :	orExpression { $exp = $orExpression.exp; }
        (ASSIGN expression { $exp = new BinaryExpression($exp, $expression.exp, BinaryOperator.assign); $exp.setLine($ASSIGN.getLine()); } )?
    ;

orExpression
	returns [Expression exp]
    :	andExpression { $exp = $andExpression.exp; }
        (OR andExpression { $exp = new BinaryExpression($exp, $andExpression.exp, BinaryOperator.or); $exp.setLine($OR.getLine()); } )*
    ;

andExpression
	returns [Expression exp]
    :	equalityExpression { $exp = $equalityExpression.exp; }
        (AND equalityExpression { $exp = new BinaryExpression($exp, $equalityExpression.exp, BinaryOperator.and); $exp.setLine($AND.getLine()); } )*
    ;

equalityExpression
	returns [Expression exp]
    locals [BinaryOperator op, int line]
    : relationalExpression { $exp = $relationalExpression.exp; }
        ( (EQ { $op = BinaryOperator.eq; $line = $EQ.getLine(); } | NEQ { $op = BinaryOperator.neq; $line = $NEQ.getLine(); })
        relationalExpression { $exp = new BinaryExpression($exp, $relationalExpression.exp, $op); $exp.setLine($line); })*
    ;

relationalExpression
	returns [Expression exp]
	locals[BinaryOperator op, int line]
    : additiveExpression { $exp = $additiveExpression.exp; }
(
	( LT { $op = BinaryOperator.lt; $line = $LT.getLine(); } | GT { $op = BinaryOperator.gt; $line = $GT.getLine(); })
        additiveExpression { $exp = new BinaryExpression($exp, $additiveExpression.exp, $op); $exp.setLine($line); })*
    ;

additiveExpression
	returns [Expression exp]
    locals [BinaryOperator op, int line]
    : multiplicativeExpression { $exp = $multiplicativeExpression.exp; }
(
	( PLUS { $op = BinaryOperator.add; $line = $PLUS.getLine(); } | MINUS { $op = BinaryOperator.sub; $line = $MINUS.getLine(); })
        multiplicativeExpression { $exp = new BinaryExpression($exp, $multiplicativeExpression.exp, $op); $exp.setLine($line); })*
    ;

multiplicativeExpression
	returns [Expression exp]
    locals [BinaryOperator op, int line]
    : preUnaryExpression { $exp = $preUnaryExpression.exp; }
    (
        (
            MULT { $op = BinaryOperator.mult; $line = $MULT.getLine(); }
            | DIV { $op = BinaryOperator.div; $line = $DIV.getLine(); }
            | PERCENT { $op = BinaryOperator.mod; $line = $line = $PERCENT.getLine(); }
        )
        preUnaryExpression { $exp = new BinaryExpression($exp, $preUnaryExpression.exp, $op); $exp.setLine($line); }
    )*
    ;

preUnaryExpression
	returns [Expression exp]
    :   NOT preUnaryExpression { $exp = new UnaryExpression(UnaryOperator.not, $preUnaryExpression.exp); $exp.setLine($NOT.getLine()); }
    |   MINUS preUnaryExpression { $exp = new UnaryExpression(UnaryOperator.minus, $preUnaryExpression.exp); $exp.setLine($MINUS.getLine()); }
    |   PLUSPLUS preUnaryExpression { $exp = new UnaryExpression(UnaryOperator.preinc, $preUnaryExpression.exp); $exp.setLine($PLUSPLUS.getLine()); }
    |   MINUSMINUS preUnaryExpression { $exp = new UnaryExpression(UnaryOperator.predec, $preUnaryExpression.exp); $exp.setLine($MINUSMINUS.getLine()); }
    |   postUnaryExpression { $exp = $postUnaryExpression.exp; }
    ;

postUnaryExpression
	returns[Expression exp]
	locals[UnaryOperator op, int line]
    :
	    otherExpression { $exp = $otherExpression.exp; }
        (
	        (
		        PLUSPLUS { $op = UnaryOperator.postinc; $line = $PLUSPLUS.getLine(); }
		        | MINUSMINUS { $op = UnaryOperator.preinc; $line = $MINUSMINUS.getLine(); }
            )
            { $exp = new UnaryExpression($op, $exp); $exp.setLine($line); }
        )?
    ;

otherExpression
	returns [Expression exp]
    : LPAREN expression { $exp = $expression.exp; } RPAREN
	| identifier { $exp = $identifier.id; }
    | arrayCall { $exp = $arrayCall.exp; }
    | actorVarAccess { $exp = $actorVarAccess.exp; }
    | value { $exp = $value.val; }
    | SENDER { $exp = new Sender(); $exp.setLine($SENDER.getLine()); }
    ;

arrayCall
	returns [ArrayCall exp]
    locals [Expression arrayInstance]
    :
	(
		identifier { $arrayInstance = $identifier.id; }
        | actorVarAccess { $arrayInstance = $actorVarAccess.exp; }
    )
    LBRACKET
        expression { $exp = new ArrayCall($arrayInstance, $expression.exp); $exp.setLine($arrayInstance.getLine()); }
    RBRACKET
    ;

actorVarAccess
	returns [ActorVarAccess exp]
    : SELF DOT identifier { $exp = new ActorVarAccess($identifier.id); $exp.setLine($SELF.getLine()); }
    ;

expressionList
	returns [ArrayList<Expression> exps]
    :
        { $exps = new ArrayList<Expression>(); }
        (expression { $exps.add($expression.exp); }
        (COMMA expression { $exps.add($expression.exp); })* |)

    ;

identifier returns [Identifier id]
    :
	IDENTIFIER {$id = new Identifier($IDENTIFIER.text); $id.setLine($IDENTIFIER.getLine()); }
    ;

value returns [Value val]
    :
	INTVAL { $val = new IntValue($INTVAL.int, new IntType()); $val.setLine($INTVAL.getLine()); }
    | STRINGVAL { $val = new StringValue($STRINGVAL.text, new StringType()); $val.setLine($STRINGVAL.getLine()); }
    | TRUE { $val = new BooleanValue(true, new BooleanType()); $val.setLine($TRUE.getLine()); }
    | FALSE { $val = new BooleanValue(false, new BooleanType()); $val.setLine($FALSE.getLine()); }
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
