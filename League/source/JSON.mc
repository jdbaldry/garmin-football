import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

function toJson(anything) as String {
    switch (anything) {
        case instanceof Lang.Boolean:
            return anything ? "true" : "false";

        case instanceof Lang.String:
            return "\"" + anything + "\"";

        case instanceof Lang.Number:
            return anything.toString();

        case instanceof Lang.Array:
            var str = "[";

            for (var j = 0; j < anything.size(); j++) {
                if (j != 0) {
                    str += ", ";
                }
                str += toJson(anything[j]);
            }
            str += "]";

            return str;

        default:
            if (anything has :toString) {
                return "\"" + anything.toString() + "\"";
            } else {
                throw new Lang.InvalidValueException(
                    "Cannot convert " + anything + " to JSON"
                );
            }
    }
}

function jsonLog(pairs as Array<String>) as Void {
    // {"T":"<TIMESTAMP>"
    var line = "{\"T\":\"" + HHMMSS(Time.now()) + "\"";

    for (var i = 0; i < pairs.size(); i += 2) {
        // ,"<KEY>":
        var key = pairs[i];
        line += ",";
        line += toJson(key);
        line += ":";

        if (i + 1 < pairs.size()) {
            // <VALUE>
            var value = pairs[i + 1];
            line += "" + toJson(value);
        } else {
            line += " \"MISSING\"";
        }
    }
    line += "}";

    System.println(line);
}
