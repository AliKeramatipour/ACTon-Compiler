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
	LPAR knownActorsList? RPAR
    COLON
    LPAR callArguments? RPAR
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
    ((primitiveType) IDENTIFIER
    | INT IDENTIFIER LBRACK INTEGER_LITERAL RBRACK) SEMI
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

curlyBlock:
    LCURLY
        commandLine*
    RCURLY
    ;

varAssigment:
	IDENTIFIER ASSIGN argument
    ;

knownActorsList:
	IDENTIFIER (COMMA knownActorsList)?
    ;

callArguments:
    argument (COMMA callArguments)?
    ;

argument:
    arithmeticStatement
    ;

methodCall  :
	(( idSelfSender DOT IDENTIFIER) | PRINT)
        LPAR
            callArguments?
        RPAR
    ;

arithmeticStatement: // without semi-colon at the end
    //level 11 few assigments
    varAssigment
    //level 10 inlineIf
    | qMarkLessArithmeticStatement (QMARK arithmeticStatement COLON arithmeticStatement)?
    ;

qMarkLessArithmeticStatement:
    //level 9 OR
    orLessArithmeticStatement (OR qMarkLessArithmeticStatement)?
    ;

orLessArithmeticStatement:
    //level 8 AND
    andLessArithmeticStatement (AND orLessArithmeticStatement)?
    ;

andLessArithmeticStatement:
    //level 7 comparative equality
	eqLessArithmeticStatement (equalityOperator andLessArithmeticStatement)?
    ;

eqLessArithmeticStatement:
    //level 6 comparative
	compLessArithmeticStatement (comparisonOperator eqLessArithmeticStatement)?
    ;

compLessArithmeticStatement:
    //level 5 ADD or SUB
	addLessArithmeticStatement (additiveOperator compLessArithmeticStatement)?
    ;

addLessArithmeticStatement:
    //level 4 MUL or DIV or MOD
	multLessArithmeticStatement (multiplicativeOperator addLessArithmeticStatement)?
    ;

multLessArithmeticStatement:
    //level 3 single operand pre
	(prefixUnaryOperator multLessArithmeticStatement )
    //level 2 using array blocks
    | (IDENTIFIER LBRACK arithmeticStatement RBRACK)
	//level 2 single operand post
    | (IDENTIFIER postfixUnaryOperator)
    //level 1 parentheses
    | (LPAR arithmeticStatement RPAR)
    //level 0 single identifire or number
	| (BOOL_LITERAL | INTEGER_LITERAL | STRING_LITERAL | idSelfSender |  (SELF DOT IDENTIFIER) )
    ;

idSelfSender:
    SENDER | SELF | IDENTIFIER
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

prefixUnaryOperator: INC | DEC | NOT | SUB;

// Literals
INTEGER_LITERAL: Digits;

BOOL_LITERAL: TRUE | FALSE;

STRING_LITERAL: '"' (~["\r\n])* '"';

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

