parser grammar ACTonParser;

options {
	tokenVocab = ACTonLexer;

}

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

actorDeclaration:
    ACTOR LCURLY
        actorBlock
	RCURLY
    ;

mainDeclaration:
    MAIN LCURLY
        mainBlock
    RCURLY
    ;

mainBlock:

    ;

actorBlock:

    ;

