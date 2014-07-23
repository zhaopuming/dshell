module dshell.util.io;
import scriptlike;

/**
 * Find all file paths with a wildcard pattern
 */
string[] find_all(string dir, string pattern)
{
	string[] expDirs; // expanded directories from wildargv expansion on arg
	// expand the wildargs for the single level. Don't follow links
	try {
		auto dFiles = dirEntries(dir, pattern, SpanMode.depth, false);
		foreach(d; dFiles) {
			expDirs ~= d.name;
		}
	} catch (FileException e) {
		// return [];
	}
	return expDirs;

}
/**
 * Find all file paths with a basename
 */
string[] find_all(string arg)
{
	string[] expDirs; // expanded directories from wildargv expansion on arg
	string basename = baseName(arg);
	string dirname = dirName(arg);

	try {
		// expand the wildargs for the single level. Don't follow links
		auto dFiles = dirEntries(dirname, basename, SpanMode.shallow, false);
		foreach(d; dFiles) {
			expDirs ~= d.name;
		}
	} catch (FileException e) {
		// directly return empty
	}
	return expDirs;
}

/**
 * find the first file path with a wildcard pattern
 */
string find_first(string path)
{
	// TODO: performance slow
	string[] r = find_all(path);
	if (r.length > 0) {
		return r[0];
	} else {
		return path;
	}
}

/**
 * Similar to bash tail -n
 **/
string[] tail(string path, int n) {
	import std.conv: to;
	auto res = executeShell("tail -n " ~ n.to!string  ~ " " ~ path);
	if (res.status == 0) {
		import std.string: strip, splitLines;
		string tails = res.output.strip;
		return tails.splitLines();
	} else {
		import std.stdio: writeln;
		writeln("Error tailing file: ", path);
		return [];
	}
}

string lookup(string file, string[] dirs...)
{
	// TODO: implement
	return file;
}

unittest
{
	string[] tails = "source/dshell/util/io.d".tail(5);
	import std.stdio;
	import std.array;
	writeln(tails.join("\n"));
}