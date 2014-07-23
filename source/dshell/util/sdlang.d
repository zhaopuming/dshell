module dshell.util.sdlang;
public import sdlang;

/**
 * Find one child tag.
 **/
Tag tag(Tag parent, string name)
{
	return parent.maybe.tags[name][0];
}


/**
 * Find one child attribute and return its value.
 */
T attr(T = string)(Tag tag, string name)
{
	try {
		return tag.maybe.attributes[name][0].value.get!T;
	} catch (Exception e) {
		// TODO: use a better mechanism instead of try..catch
		return T.init;
	}
}

/**
 * Find one attribute, if not exist, try the parent tag.
 **/
T attr(T = string)(Tag tag, string name, Tag parent)
{
	try {
		return tag.maybe.attributes[name][0].value.get!T;
	} catch (Exception e) {
		// TODO: ditto
		return parent.attr!T(name);
	}
}

/**
 * Get the first value of a tag.
 **/
T val(T = string)(Tag tag)
{
	try {
		// no maybe for values
	return tag.values[0].get!T;
	} catch (Exception e) {
		return T.init; 
	}
}
