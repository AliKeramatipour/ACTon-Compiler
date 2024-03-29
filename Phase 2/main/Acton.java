package main;

import main.ast.node.Program;
import main.compileError.CompileErrors;
import main.visitor.ASTPrinter;
import main.visitor.NameAnalyser;
import main.visitor.SecondNameAnalyser;
import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import main.parsers.actonLexer;
import main.parsers.actonParser;

import java.io.IOException;

// Visit https://stackoverflow.com/questions/26451636/how-do-i-use-antlr-generated-parser-and-lexer
public class Acton {
    public static void main(String[] args) throws IOException {
        CharStream reader = CharStreams.fromFileName(args[1]);
        actonLexer lexer = new actonLexer(reader);
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        actonParser parser = new actonParser(tokens);
        Program program = parser.program().p; /* assuming that the name of the Program ast node
                                                 that the program rule returns is p */
        program.accept(new NameAnalyser());
        program.accept(new SecondNameAnalyser());
        if (CompileErrors.hasErrors()) {
            CompileErrors.print();
        } else {
            program.accept(new ASTPrinter());
        }
    }
}
