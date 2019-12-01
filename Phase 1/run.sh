# FLAGS=-gui # -diagnostics
export CLASSPATH=".:/usr/local/lib/antlr-4.7.2-complete.jar:$CLASSPATH"
java -jar /usr/local/lib/antlr-4.7.2-complete.jar ACTonParser.g4
javac *.java
java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/1.act > testcases/1.out
java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/2.act > testcases/2.out
java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/3.act > testcases/3.out
java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/4.act > testcases/4.out
java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/5.act > testcases/5.out
java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/6.act > testcases/6.out
java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/7.act > testcases/7.out
make clean
