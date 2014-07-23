module dshell.util.date;
import std.datetime;
import std.string;
import std.conv: to;
import std.traits;

/**
 * Parse 'YYMMDDHH' format datetime string
 **/
DateTime parseHour(string s)
{
	if ("now" == s) {
		return cast(DateTime)(Clock.currTime);
	}
	if ("lasthour" == s) {
		return cast(DateTime)(Clock.currTime) - 1.hours;
	}
	if (s.startsWith("-")) {
		int n = s[1..$].to!int;
		return cast(DateTime)(Clock.currTime) - n.hours;
	}
	// TODO: check date string format
	import std.conv: to;
	int year = s[0..4].to!int;
	int month = s[4..6].to!int;
	int day = s[6..8].to!int;
	int hour = s[8..10].to!int;
	return DateTime(year, month, day, hour);
}

/**
 * Convert a DateTime to 'YYMMDDHH' format
 **/
string toHourString(DateTime dt)
{
	return dt.date.toISOString~dt.timeOfDay.toISOString[0..2];
}

/**
 * Get the last hour
 **/
DateTime lastHour()
{
	import std.datetime;
	return cast(DateTime)(Clock.currTime) - 1.hours;
}
