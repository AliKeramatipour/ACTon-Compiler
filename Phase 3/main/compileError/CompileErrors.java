package main.compileError;

import java.util.*;

public class CompileErrors {
    private static HashMap<Integer, ArrayList<String>> errors = new HashMap<>();;

    public static void add(Integer line, String errorMessage) {
        ArrayList<String> lineErrors;
        if (errors.containsKey(line)) {
            lineErrors = errors.get(line);
        } else {
            lineErrors = new ArrayList<String>();
        }
        lineErrors.add(errorMessage);
        errors.put(line, lineErrors);
    }

    public static boolean hasErrors() {
        return !errors.isEmpty();
    }

    public static void print() {
        SortedSet<Integer> lines = new TreeSet<>(errors.keySet());
        for (Integer line : lines) {
            ArrayList<String> lineErrors = errors.get(line);
            Collections.sort(lineErrors, new ErrorSorter());
            for (String errorMessage : lineErrors) {
                System.out.println("Line:" + line + ":" + errorMessage);
            }
        }
    }
}

class ErrorSorter implements Comparator<String>
{
    public int compare(String a, String b)
    {
        if (a.charAt(0) == 'C' && b.charAt(0) == 'Q') {
            return -1;
        }
        if (a.charAt(0) == 'R' && b.charAt(0) == 'Q') {
            return -1;
        }
        if (a.charAt(0) == 'R' && b.charAt(0) == 'A') {
            return -1;
        }
        return 0;
    }
}