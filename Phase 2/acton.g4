grammar acton;

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
	returns[InitHandlerDeclaration initHandlerDec]
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

varDeclarations returns[ArrayList<VarDeclaration> varDecs]
    :
	{ $varDecs = new ArrayList<>(); }
    (varDeclaration SEMICOLON { $varDecs.add($varDeclaration.varDec); } )*
    ;

varDeclaration returns[VarDeclaration varDec] locals [Type t, Identifier id]
:
	(INT identifier { $t = new IntType(); $id = $identifier.identifier }
    | STRING identifier { $t = new StringType(); $id = $identifier.identifier }
    | BOOLEAN identifier { $t = new BooleanType(); $id = $identifier.identifier }
    | INT identifier LBRACKET INTVAL RBRACKET { $t = new ArrayType(); $t.setSize($INTVAL.int); $id = $identifier.identifier })
    {$varDec = new VarDeclaration($id, $t);}
    ;

statement
	returns[Statement stmt]
    :	blockStmt
    | 	printStmt
    |  	assignStmt
    |  	forStmt
    |  	ifStmt
    |  	continueStmt
    |  	breakStmt
    |  	msgHandlerCall
    ;

blockStmt
    : 	LBRACE (statement)* RBRACE
    ;

printStmt
    : 	PRINT LPAREN expression RPAREN SEMICOLON
    ;

assignStmt
    :    assignment SEMICOLON
    ;

assignment
    :   orExpression ASSIGN expression
    ;

forStmt
    : 	FOR LPAREN (assignment)? SEMICOLON (expression)? SEMICOLON (assignment)? RPAREN statement
    ;

ifStmt
    :   IF LPAREN expression RPAREN statement elseStmt
    ;

elseStmt
    : ELSE statement |
    ;

continueStmt
    : 	CONTINUE SEMICOLON
    ;

breakStmt
    : 	BREAK SEMICOLON
    ;

msgHandlerCall
    :   (identifier | SELF | SENDER) DOT
        identifier LPAREN expressionList RPAREN SEMICOLON
    ;

expression
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
    :	(expression(COMMA expression)* | )
    ;

identifier returns [Identifier identifier]
    : IDENTIFIER {$identifier = new Identifier($IDENTIFIER.text); }
    ;

value
    :   INTVAL | STRINGVAL | TRUE | FALSE
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
