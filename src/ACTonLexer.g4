lexer grammar ACTonLexer;

// Keywords
MAIN:               'main';
PRINT:              'print';

IF:                 'if';
ELSE:               'else';

INT:                'int';
BOOLEAN:            'boolean';
STRING:             'string';

TRUE:               'true';
FALSE:              'false';

FOR:                'for';
BREAK:              'break';
CONTINUE:           'continue';

MSGHANDLER:         'msghandler';
INITIAL:            'initial';
EXTENDS:            'extends';
ACTOR:              'actor';
ACTORVARS:          'actorvars';
KNOWNACTORS:        'knownactors';
SELF:               'self';
SENDER:             'sender';


// Operators

// arithmetic
ADD:                '+';
INC:                '++';
SUB:                '-';
DEC:                '--';
MUL:                '*';
DIV:                '/';
MOD:                '%';

// compartive
EQ:                 '==';
NE:                 '!=';
GT:                 '>';
LT:                 '<';

// logical
NOT:                '!';
AND:                '&&';
OR:                 '||';

// other
ASSIGN:             '=';

QMARK:              '?';
COLON:              ':';



// Separators
SEMI:               ';';

LPAR:               '(';
RPAR:               ')';

LBRACK:             '[';
RBRACK:             ']';

LCURLY:             '{';
RCURLY:             '}';

COMMA:              ',';
DOT:                '.';

// Literals

INTEGER_LITERAL: Digits;

BOOL_LITERAL: TRUE | FALSE;

STRING_LITERAL: '"' (~["\r\n])* '"';

// Identifiers
IDENTIFIER:         Letter LetterOrDigit*;

// Whitespace and comments
WS: [ \t\r\n]+         -> skip;
COMMENT: '//' ~[\r\n]* -> skip;


// Fragment rules
fragment Digit: [0-9];
fragment Digits: Digit+;

fragment Letter: [a-zA-Z_];

fragment LetterOrDigit: Letter | Digit;

