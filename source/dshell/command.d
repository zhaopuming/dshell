module dshell.command;
import std.stdio;

import dshell.global;
import dshell.config;
import std.logger;

alias string delegate(string[]) Handler;
class Command 
{
	immutable {
		string name;
		Handler handler;
	}

	this(string name, Handler handler)
	{
		this.name = name;
		this.handler = handler;
	}

	this(string name, string function(string[]) handler)
	{
		import std.functional: toDelegate;
		this(name, handler.toDelegate);
	}
}

void execute(Handler handler, string[] args)
{
	import std.stdio;
	writeln(handler(args));
}

void exec(inout Command cmd, string[] args)
{
	cmd.handler.execute(args);
}

void exec(Alias a, string[] args)
{
	a.root.exec(args);
}


class Alias : Command
{
	immutable Command root;

	public this(string name, Command cmd)
	{
		super(name, cmd.handler);
		this.root = cast(immutable)cmd;
	}
}


unittest
{
	import std.stdio: writeln;

	auto f = (string[] xs) => xs[0];
	writeln(typeid(f));
	auto cmd = new Command("hello", f);
	cmd.handler.execute;

	A a = new A(3, 4);
	immutable c = a.freeze;
	a.b.b = 7;
	writeln(c.b.b);
}