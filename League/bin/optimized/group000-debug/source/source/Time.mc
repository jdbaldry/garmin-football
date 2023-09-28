using Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Time;

// Format the given timer time as a "MM:SS" string.
function timerTimeToString(timerTime as Number) as String {
  timerTime /*>timerValue<*/ = Gregorian /*>Time.Gregorian<*/.duration({
    :seconds => (timerTime * 0.001).toNumber(),
  }).value();
  return (
    (timerTime /*>timerValue<*/ / 60).format("%02d") +
    ":" +
    (timerTime /*>timerValue<*/ % 60).format("%02d")
  );
}

// Format the moment in RFC 3339 format with second level precision.
// Example: 2006-08-14 02:34:56
// Format the moment as a "YYYYMMDD" string.
public function YYYYMMDD(moment as Moment) as String {
  moment /*>info<*/ = Gregorian /*>Time.Gregorian<*/.info(
    moment,
    0 as Toybox.Time.DateFormat
  );

  return Lang.format("$1$$2$$3$", [
    moment /*>info<*/.year.format("%04d"),
    moment /*>info<*/.month.format("%02d"),
    moment /*>info<*/.day.format("%02d"),
  ]);
}

// Format the moment as a "HHMMSS" string.
public function HHMMSS(moment as Moment) as String {
  var pre___02d_;
  pre___02d_ = "%02d";
  moment /*>info<*/ = Gregorian /*>Time.Gregorian<*/.info(
    moment,
    0 as Toybox.Time.DateFormat
  );

  return Lang.format("$1$$2$$3$", [
    moment /*>info<*/.hour.format(pre___02d_),
    moment /*>info<*/.min.format(pre___02d_),
    moment /*>info<*/.sec.format(pre___02d_),
  ]);
}
