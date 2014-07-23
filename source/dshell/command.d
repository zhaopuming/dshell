module dshell.command;
import std.stdio;

import dshell.util.config;
void process(string cmd, ConfigManager conf)
{
	import std.string: split, strip;
	import std.algorithm: strip, map;
	import std.array: array;
	string[] args = cmd.split.map!((string x) => x.strip).array;
	switch (args[0]) {
		case "servers":
			import std.array: join;
			writeln(conf.servers.map!(x => x.toString).join("\n"));
			break;
		default:
			import scriptlike: tryRun;
			tryRun(cmd);
			break;
	}
}

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

void execute(Handler handler)
{
	import std.stdio;
	writeln(handler(["Handler", "2"]));
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