import std.stdio, core.stdc.string, core.stdc.stdlib;
import deimos.linenoise;

import std.stdio;
extern(C) void completion(const char *buf, linenoiseCompletions *lc) {
	if (buf[0] == 'h') {
		linenoiseAddCompletion(lc,"hello");
		linenoiseAddCompletion(lc,"hello there");
	} else if (buf[0] == 'i') {
		linenoiseAddCompletion(lc,"init");
	}
}

import dshell.util.config;
ConfigManager confManager;

void checkConfig()
{
	string path = "config.sdl".lookupConfig;
	string serversPath = "servers.sdl".lookupConfig;
	confManager = new ConfigManager(path, serversPath);
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
	while((line = linenoise("hello> ")) !is null) {
		/* Do something with the string. */
		if (line[0] != '\0' && line[0] != '/') {
			printf("echo: '%s'\n", line);
			linenoiseHistoryAdd(line); /* Add to the history. */
			linenoiseHistorySave("history.txt"); /* Save the history on disk. */
			import std.conv: to;
			string cmd = line.to!string;
			if (cmd == "quit" || cmd == "exit" || cmd == "bye") {
				break;
			} else {
				cmd.process(confManager);
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
