module dshell.util.remote;
import scriptlike;
import std.stdio;
import dshell.util.server;


void rcallServer(Server server, string cmd, bool isInit=false)
{
	string stmt = server.ssh(cmd);
	if (isInit) {
		writeln("password:");
		writeln(server.pwd);
	}
	writeln(server.prompt ~ stmt);
	auto res = executeShell(stmt);
	if (res.status != 0) {
		writeln("error!");
		writeln(res.output);
	} else {
		writeln(res.output);
	}
	writeln("remote@" ~ server.name ~ "-> END --------");
}
