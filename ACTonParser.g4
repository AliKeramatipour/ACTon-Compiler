grammar ACTonParser;

@members {
   void print(Object obj){
        System.out.print(obj);
   }

   void printEmptyLine(){
        System.out.println("");
   }

   void printLine(Object obj){
        System.out.println(obj);
   }
}

actonParser:
	actorDeclaration*
	mainDeclaration
    EOF
;

mainDeclaration:
    MAIN LCURLY
        actorInstantiation*
    RCURLY
    ;

// First IDENTIFIER is Actor name
actorInstantiation:
    IDENTIFIER IDENTIFIER
	LPAR knownActorsList RPAR
    COLON
    LPAR callArguments RPAR
    SEMI
    ;

actorDeclaration:
	ACTOR (EXTENDS IDENTIFIER)?
    LPAR INTEGER_LITERAL RPAR
    LCURLY
        actorBlock
	RCURLY
    ;

actorBlock:
    KNOWNACTORS LCURLY
        (IDENTIFIER IDENTIFIER SEMI)*
    RCURLY
	ACTORVARS LCURLY
        (type IDENTIFIER SEMI)*
    RCURLY
	initializerDeclaration?
    msgHandlerDeclaration*
    ;

initializerDeclaration:
    MSGHANDLER INITIAL
	arguments
	msgHandlerBlock
    ;

msgHandlerDeclaration:
    MSGHANDLER IDENTIFIER
	arguments
    msgHandlerBlock
    ;

msgHandlerBlock:
	LCURLY

    RCURLY
    ;

knownActorsList:
	IDENTIFIER (COMMA knownActorsList)?
    ;

arithmeticBlock:
    ;

callArguments:
    arithmeticBlock (COMMA callArguments)?
	;

arguments:
	LPAR (
        (type IDENTIFIER)
		(
            COMMA type IDENTIFIER
		)*
	)? RPAR;

type: primitiveType;

primitiveType: INT | STRING | BOOLEAN;



// Keywords
MAIN: 'main';
PRINT: 'print';

IF: 'if';
ELSE: 'else';

INT: 'int';
STRING: 'string';
BOOLEAN: 'boolean';

TRUE: 'true';
FALSE: 'false';

FOR: 'for';
BREAK: 'break';
CONTINUE: 'continue';

MSGHANDLER: 'msghandler';
INITIAL: 'initial';
EXTENDS: 'extends';
ACTOR: 'actor';
ACTORVARS: 'actorvars';
KNOWNACTORS: 'knownactors';
SELF: 'self';
SENDER: 'sender';

// Operators

// arithmetic
ADD: '+';
INC: '++';
SUB: '-';
DEC: '--';
MUL: '*';
DIV: '/';
MOD: '%';

// compartive
EQ: '==';
NE: '!=';
GT: '>';
LT: '<';

// logical
NOT: '!';
AND: '&&';
OR: '||';

// other
ASSIGN: '=';

QMARK: '?';
COLON: ':';

// Separators
SEMI: ';';

LPAR: '(';
RPAR: ')';

LBRACK: '[';
RBRACK: ']';

LCURLY: '{';
RCURLY: '}';

COMMA: ',';
DOT: '.';

// Literals

INTEGER_LITERAL: Digits;

BOOL_LITERAL: TRUE | FALSE;

STRING_LITERAL: '"' (~["\r\n])* '"';

// Identifiers
IDENTIFIER: Letter LetterOrDigit*;

// Whitespace and comments
WS: [ \t\r\n]+ -> skip;
COMMENT: '//' ~[\r\n]* -> skip;

// Fragment rules
fragment Digit: [0-9];
fragment Digits: Digit+;

fragment Letter: [a-zA-Z_];

fragment LetterOrDigit: Letter | Digit;

