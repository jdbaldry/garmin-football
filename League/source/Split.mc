import Toybox.Lang;
import Toybox.Test;

function split(str as String, sep as String) as Array<String> {
    var parts = [] as Array<String>;
    var index = str.find(sep);

    while (index) {
        parts.add(str.substring(0, index));
        str = str.substring(index + sep.length(), str.length());
        index = str.find(sep);
    }

    parts.add(str);

    return parts;
}

(:test)
function testSplit(logger as Logger) as Boolean {
    var in = "A,B,C";
    var want = ["A", "B", "C"];
    var got = split(in, ",");

    logger.debug("want: " + want.toString());
    logger.debug(" got: " + got.toString());

    return got.toString().equals(want.toString());
}
