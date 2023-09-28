import Toybox.Lang;
import Toybox.Test;

function join(arr as Array<String>, sep as String) as String {
    var joined = "";

    for (var i = 0; i < arr.size(); i++) {
        if (i != 0) {
            joined += sep;
        }
        joined += arr[i];
    }

    return joined;
}

(:test)
function testJoin(logger as Logger) as Boolean {
    var in = ["A", "B", "C"];
    var want = "A,B,C";
    var got = join(in, ",");

    logger.debug("want: " + want.toString());
    logger.debug(" got: " + got.toString());

    return got.toString().equals(want.toString());
}
