import std.stdio, core.stdc.string, core.stdc.stdlib;
import deimos.linenoise;

import std.stdio;
import dshell.global;

extern(C) void completion(const char *buf, linenoiseCompletions *lc) {
	if (buf[0] == 'h') {
		linenoiseAddCompletion(lc, "hello");
		linenoiseAddCompletion(lc, "hello there");
	} else if (buf[0] == 'i') {
		linenoiseAddCompletion(lc, "init");
	} else {
		import dshell.config;
		import std.string: toStringz;
		string[] completions = confManager.getCompletions(buf[0]);
		foreach (completion; completions) {
			linenoiseAddCompletion(lc, completion.toStringz);
		}
	}
}

void checkConfig()
{
	string path = "config.sdl".lookupConfig;
	string serversPath = "servers.sdl".lookupConfig;
	import dshell.config;
	confManager = new ConfigManager(path, serversPath);
	import dshell.command;
	initCommands();
	writeln(confManager.commands);
}


string lookupConfig(string config)
{
	import dshell.util.io: lookup;
	string path = config.lookup(".", "~/.dshell/", "/etc/dshell");
	return path;
}

import dshell.command;

int main(string[] args)
{

	import colorize;

	cwriteln("This is red".color(fg.red));

	char *line;
	auto prgname = args[0];

	/* Parse options, with --multiline we enable multi line editing. */
	foreach (arg; args[1 .. $]) {
		if (arg == "--multiline") {
			linenoiseSetMultiLine(1);
			writeln("Multi-line mode enabled.");
		} else {
			stderr.writefln("Usage: %s [--multiline]", prgname);
			return 1;
		}
	}
	
	/* Set the completion callback. This will be called every time the
     * user uses the <tab> key. */
	linenoiseSetCompletionCallback(&completion);
	
	/* Load history from file. The history file is just a plain text file
     * where entries are separated by newlines. */
	linenoiseHistoryLoad("history.txt"); /* Load the history at startup */

	// check config file
	checkConfig();

	/* Now this is the main loop of the typical linenoise-based application.
     * The call to linenoise() will block as long as the user types something
     * and presses enter.
     *
     * The typed string is returned as a malloc() allocated string by
     * linenoise, so the user needs to free() it. */
	while((line = linenoise("dshell> ")) !is null) {
		/* Do something with the string. */
		if (line[0] != '\0' && line[0] != '/') {
			linenoiseHistoryAdd(line); /* Add to the history. */
			linenoiseHistorySave("history.txt"); /* Save the history on disk. */
			import std.conv: to;
			string cmd = line.to!string;
			if (cmd == "quit" || cmd == "exit") {
				break;
			} else {
				cmd.process();
			}
		} else if (!strncmp(line,"/historylen",11)) {
			/* The "/historylen" command will change the history len. */
			int len = atoi(line+11);
			linenoiseHistorySetMaxLen(len);
		} else if (line[0] == '/') {
			printf("Unreconized command: %s\n", line);
		}
		free(line);
	}
	return 0;
}



void initCommands()
{
	import dshell.config;
	auto cmds = confManager.commands;
	
	cmds["servers"] = new Command("servers", (string[] args) { 
		import std.array: join;
		import std.algorithm: map;
		import colorize;
		cwriteln(confManager.servers.map!(x => x.toString).join("\n").color(fg.light_red));
		return "";
	});
	
	Command bye = new Command("bye", (string[] args) {
		writeln("Byebye");
		import core.stdc.stdlib: exit;
		exit(0);
		return "";
	});

	cmds["bye"] = bye;
	cmds["quit"] = new Alias("quit", bye);
	
	cmds["remote"] = new Command("remote", (string[] args) {
		writeln("Args: ", args);
		import dshell.util.server;
		import std.string: join;
		foreach (server; confManager.servers) {
			server.run(args.join(" "));
		}
		return "";
	});

}

void process(string cmd)
{
	import dshell.config;
	Command[string] commands = confManager.commands; 
	import std.string: split, strip;
	import std.algorithm: strip, map;
	import std.array: array;
	string[] args = cmd.split.map!((string x) => x.strip).array;
	if (auto c = args[0] in commands) {
		(*c).exec(args[1..$]);
	} else {
		// if other commands, just delegate to the system shell
		import scriptlike: tryRun;
		tryRun(cmd);
	}
}
