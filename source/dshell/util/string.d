module dshell.util.string;

string ltick(string left, string right)
{
	import std.algorithm: empty;
	return right.empty ? "" : left ~ right;
}

string rtick(string left, string right)
{
	import std.algorithm: empty;
	return left.empty ? "" : left ~ right;
}

