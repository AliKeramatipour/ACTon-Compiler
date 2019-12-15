package main.symbolTable;

import main.ast.type.Type;

public abstract class SymbolTableItem {
	protected String name;

	private boolean visited = false;

	public void visit() {
		visited = true;
	}

	public void unVisit () {
		visited = false;
	}

	public boolean isVisited() {
		return visited;
	}

	public SymbolTableItem() {
	}

	public abstract String getKey();
}