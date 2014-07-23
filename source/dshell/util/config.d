module dshell.util.config;
import dshell.util.sdlang;

class ConfigManager
{
	private Config _config;
	public Server[] servers;

	this(string path, string serversPath)
	{
		import std.file: readText;
		string text = readText(path);
		this._config = parseConfig(text);
		this.servers = parseServers(serversPath);
	}

	@property Config config() pure
	{
		return this._config;
	}
}

Config parseConfig(string text)
{
	Config c = new Config();
	return c;
}

Server[] parseServers(string path)
{
	Tag servers = parseFile(path);
	return parseServers(servers);
}

Server[] parseServers(Tag tag)
{
	Server[] servers;
	foreach (server; tag.tags) {
		Server s = new Server();

		import std.stdio: writeln;
		s.name = server.name;
		s.ip = server.attr("ip");
		s.user = server.attr("user");
		s.port = server.attr("port");
		s.type = server.attr("type");
		s.pwd = server.attr("pwd");

		servers ~= s;
	}
	return servers;
}

class Config
{
	private Server[] servers;

	
}

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
