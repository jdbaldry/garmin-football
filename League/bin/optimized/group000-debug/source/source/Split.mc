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
