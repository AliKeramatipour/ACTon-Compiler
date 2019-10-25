build: obj src/ACTonLexer.g4 src/ACTonParser.g4
	export CLASSPATH="/usr/local/lib/antlr-4.2.2-complete.jar"
	java -jar /usr/local/lib/antlr-4.7.2-complete.jar src/ACTonLexer.g4
	java -jar /usr/local/lib/antlr-4.7.2-complete.jar src/ACTonParser.g4
	javac src/*.java

run: clean build
	java org.antlr.v4.gui.TestRig ACTon prog -gui < testcases/1.act

obj:
	mkdir -p obj

clean:
	rm -rf src/*.class
	rm -rf src/*.tokens
	rm -rf src/ACTonParser*.java
	rm -rf src/ACTonLexer*.java
	rm -rf src/*.interp

