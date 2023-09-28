import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

function toJson(anything) as String {
  var pre_____;
  pre_____ = "\"";
  switch (anything) {
    case instanceof Lang.Boolean:
      return anything ? "true" : "false";

    case instanceof Lang.String:
      return pre_____ + anything + pre_____;

    case instanceof Lang.Number:
      return anything.toString();

    case instanceof Lang.Array:
      pre_____ /*>str<*/ = "[";

      for (var j = 0; j < anything.size(); j += 1) {
        if (j != 0) {
          pre_____ /*>str<*/ += ", ";
        }
        pre_____ /*>str<*/ += toJson(anything[j]);
      }
      return pre_____ /*>str<*/ + "]";

    default:
      if (anything has :toString) {
        return pre_____ + anything.toString() + pre_____;
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
    line = line + "," + toJson(pairs[i]) + ":";

    if (i + 1 < pairs.size()) {
      // <VALUE>
      line += "" + toJson(pairs[i + 1]);
    } else {
      line += " \"MISSING\"";
    }
  }
  System.println(line + "}");
}
