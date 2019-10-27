FLAGS= -diagnostics # -gui

.PHONY: clean build

build: clean ACTonParser.g4
	export CLASSPATH=".:/usr/local/lib/antlr-4.7.2-complete.jar:$CLASSPATH"
	java -jar /usr/local/lib/antlr-4.7.2-complete.jar ACTonParser.g4
	javac *.java
	java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/1.act
	java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/2.act
	java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/3.act
	java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/4.act
	java org.antlr.v4.gui.TestRig ACTonParser actonParser ${FLAGS} < testcases/5.act

clean:
	rm -rf *.class
	rm -rf *.tokens
	rm -rf ACTonParser*.java
	rm -rf ACTonLexer*.java
	rm -rf *.interp

