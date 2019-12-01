# FLAGS=-gui # -diagnostics
export CLASSPATH=".:/usr/local/lib/antlr-4.7.2-complete.jar:$CLASSPATH"
java -jar /usr/local/lib/antlr-4.7.2-complete.jar acton.g4
javac *.java
java org.antlr.v4.gui.TestRig acton program ${FLAGS} < testcases/1.act > testcases/1.out
diff testcases/1.out testcases/1.sol
make clean
