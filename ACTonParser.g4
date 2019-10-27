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
	ACTOR IDENTIFIER (EXTENDS IDENTIFIER)?
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
	curlyBlockWithDeclaration
    ;

curlyBlockWithDeclaration:
    LCURLY
        varDeclaration*
        commandLine*
    RCURLY
    ;

varDeclaration:
    (primitiveType) IDENTIFIER
    | INT IDENTIFIER LBRACK INTEGER_LITERAL RBRACK
    ;

commandLine:
    forBlock | ifBlock | ifElseBlock | commandLineSemi
    ;

commandLineSemi:
    (CONTINUE
    | BREAK
    | methodCall
    | varAssigment)
    SEMI
    ;

forBlock:
    FOR LPAR (varAssigment?) SEMI (arithmeticStatement?) SEMI (varAssigment?) RPAR
        newBlock
    ;

ifBlock:
    IF LPAR arithmeticStatement RPAR
        newBlock
    ;

ifElseBlock:
    IF LPAR arithmeticStatement RPAR
        newBlock
    ELSE
        newBlock
    ;

newBlock:
    (curlyBlock | commandLine)
    ;

methodCall:
	(((SELF | SENDER | IDENTIFIER) DOT)? PRINT | IDENTIFIER )
        LPAR
            callArguments?
        RPAR
    ;

curlyBlock:
    LCURLY
        commandLine*
    RCURLY
    ;

varAssigment:
	IDENTIFIER ASSIGN (boolLiteral | STRING_LITERAL| arithmeticStatement)
    ;

boolLiteral: (TRUE | FALSE);

knownActorsList:
	IDENTIFIER (COMMA knownActorsList)?
    ;

callArguments:
    arithmeticStatement (COMMA arithmeticStatement)?
	;

arithmeticStatement: // without semi-colon at the end
    //level 11 few assigments
    varAssigment
    //level 10 inlineIf
    | qMarkLessArithmeticStatement QMARK arithmeticStatement COLON arithmeticStatement
    ;

qMarkLessArithmeticStatement:
    //level 9 OR
    orLessArithmeticStatement (OR arithmeticStatement)?
    ;

orLessArithmeticStatement:
    //level 8 AND
    andLessArithmeticStatement (AND arithmeticStatement)?
    ;

andLessArithmeticStatement:
    //level 7 comparative equality
	eqLessArithmeticStatement (equalityOperator arithmeticStatement)?
    ;

eqLessArithmeticStatement:
    //level 6 comparative
	compLessArithmeticStatement (comparisonOperator arithmeticStatement)?
    ;

compLessArithmeticStatement:
    //level 5 ADD or SUB
	addLessArithmeticStatement (additiveOperator arithmeticStatement)?
    ;

addLessArithmeticStatement:
    //level 4 MUL or DIV or MOD
	multLessArithmeticStatement (multiplicativeOperator arithmeticStatement)?
    ;

multLessArithmeticStatement:
    //level 3 single operand pre
	prefixUnaryOperator IDENTIFIER
    //level 2 using array blocks
    | IDENTIFIER LBRACK arithmeticStatement RBRACK
	//level 2 single operand post
    | IDENTIFIER postfixUnaryOperator
    //level 1 parentheses
    | LPAR arithmeticStatement RPAR
    //level 0 single identifire or number
    | INTEGER_LITERAL | IDENTIFIER
    ;

arguments:
	LPAR (
        (type IDENTIFIER)
		(COMMA type IDENTIFIER)*
	)? RPAR;

type: primitiveType | nonPrimitiveType;

nonPrimitiveType: INTARRAY;

primitiveType: INT | STRING | BOOLEAN;

equalityOperator: EQ | NE;

comparisonOperator: GT | LT;

additiveOperator: ADD | SUB;

multiplicativeOperator: MUL | DIV | AND;

postfixUnaryOperator: INC | DEC;

prefixUnaryOperator: INC | DEC | NOT;

// Keywords
MAIN: 'main';
PRINT: 'print';

IF: 'if';
ELSE: 'else';

INT: 'int';
STRING: 'string';
BOOLEAN: 'boolean';
INTARRAY: 'int[]';

TRUE : 'true';
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

