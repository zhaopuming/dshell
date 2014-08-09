module dshell.util.server;

import std.datetime;
import scriptlike;


class Server
{
	public {
		string name;
		string ip;
		string user;
		string pwd;
		string port;
		string type;
	}
	
public:
	
	@property bool isPwd() pure nothrow const
	{
		import std.string: empty;
		return pwd.empty;
	}
	
	@property override string toString()
	{
		import dshell.util.string;
		return name ~ "." ~ type ~ " = " ~ (user ~ ":".ltick(pwd)).rtick("@") ~ ip ~ ":".ltick(port);
	}
}

/**
 * Check if this server needs sshpass
 **/
@property string sshpass(ref in Server server) pure nothrow
{
	string sshpass = server.isPwd ? `sshpass -p "`~server.pwd~`" `: "";
	return sshpass;
}

/**
 * Create a ssh statement for a server
 **/ 
string ssh(ref in Server server, string cmd) pure nothrow
{
	// sshpass -p '{passwd}' ssh -p {port} {user}@{ip} {cmd}
	string sshpass = server.sshpass;
	string stmt = "ssh -p " ~ server.port~ " " ~ server.user ~ "@" ~ server.ip ~ " '" ~ cmd ~ "'"; 
	return stmt;
}

/**
 * Create a uploading rsync statement for a server
 **/
string rsyncUp(ref in Server server, string src, string dest)  pure nothrow
{
	string sshpass = server.isPwd ? `sshpass -p "`~server.pwd~`" `: "";
	// TODO: --delete?
	string stmt = `rsync --delete --rsh='`~sshpass~` ssh -p `~server.port~`' -CavuzLm `~src~` `~server.user~`@`~server.ip~`:`~dest;
	return stmt;
}

/**
 * Create a downloading rsync statement for a server.
 **/
string rsyncDown(ref in Server server, string src, string dest)
{
	string sshpass = server.isPwd ? "" : `sshpass -p "`~server.pwd~`" `;
	string stmt = `rsync --rsh='`~sshpass~` ssh -p `~server.port~`' -CavuzLm `~server.user~`@`~server.ip~`:`~src~' '~dest;
	return stmt;
}

/**
 * Create a simple prompt
 **/
string prompt(ref in Server server, string cmd = "")
{
	return "[remote] "~server.name~"@"~server.ip~server.portStr~">"~cmd;
}

string safeToString(int n) pure nothrow
{
	try {
		// TODO: how to better deal with nothrow here
		import std.conv: to;
		return n.to!string;
	} catch (Exception e) {
		return "";
	}
}

/**
 * server.port.to!string
 **/
string portStr(ref in Server server) pure nothrow
{
	if (server.port == "22") {
		return "";
	} else {
		import std.conv: to;
		try {
			// TODO: how to better deal with nothrow here
			return ":"~server.port.to!string;
		} catch (Exception e) {
			return "";
		}
	}
}

/**
 * Run a command in a remote server.
 **/
void run(ref in Server server, string cmd)
{
	string stmt = server.ssh(cmd);
	writeln(server.prompt(stmt));
	tryRun(stmt);
	writeln("~~"~server.prompt(stmt));
	writeln("Done.");
}

/**
 * Run multiple commands in order (using '&&'), in a remote server.
 **/
void batch(ref in Server server, string[] cmds...)
{
	string stmt = cmds.join(" && ");
	server.run(stmt);
}

/**
 * Run a command in all servers.
 **/
void runAll(Server[] servers, string cmd)
{
	import std.concurrency: spawn;
	foreach (Server server; servers) {
		spawn(&run, cast(immutable)server, cmd);
	}
	
}

/**
 * Batch multiple commands in order(using '&&') in all servers.
 **/
void batchAll(Server[] servers, string[] cmds...)
{
	string stmt = cmds.join(" && ");
	runAll(servers, stmt);
}

/**
 * Call a particular command on server, and catch its output.
 **/
string call(ref in Server server, string cmd)
{
	string stmt = server.ssh(cmd);
	writeln(server.prompt(stmt));
	import std.process: executeShell;
	import std.string: strip;
	auto res = executeShell(stmt);
	if (res.status == 0) {
		string result = res.output.strip;
		// TODO: use "Result: xxx" to represent result of a call
		return result;
	} else {
		writeln("Error: ", res.status);
		return "";
	}
}


unittest {
	/**
	 Server server = Server();
	 server.name = "test01";
	 server.ip = "127.0.0.1";
	 import std.process: shell;
	 import std.string: strip;
	 string whoami = shell("whoami").strip;
	 writeln("whoami:" ~ whoami);
	 server.user = whoami;
	 server.port = 22;
	 
	 writeln(server.prompt);
	 **/
	// server.run("df -h");
}