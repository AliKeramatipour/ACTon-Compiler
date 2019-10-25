# !/bin/bash

./clean.sh $1

java -jar /usr/local/lib/antlr-4.7.2-complete.jar $1Lexer.g4
java -jar /usr/local/lib/antlr-4.7.2-complete.jar $1Parser.g4

javac *.java

java org.antlr.v4.gui.TestRig $1 -gui < testcases/1.act

./clean.sh $1
