import Toybox.Lang;
import Toybox.Time;

// Format the given timer time as a "MM:SS" string.
function timerTimeToString(timerTime as Number) as String {
    var options = { :seconds => (timerTime * 0.001).toNumber() };
    var timerValue = Time.Gregorian.duration(options).value();
    var seconds = timerValue % 60;
    var minutes = timerValue / 60;

    return minutes.format("%02d") + ":" + seconds.format("%02d");
}

// Format the moment in RFC 3339 format with second level precision.
// Example: 2006-08-14 02:34:56
function rfc3339(moment as Moment) as String {
    var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);

    return Lang.format("$1$-$2$-$3$ $4$:$5$:$6$", [
        info.year.format("%04d"),
        info.month.format("%02d"),
        info.day.format("%02d"),
        info.hour.format("%02d"),
        info.min.format("%02d"),
        info.sec.format("%02d"),
    ]);
}

// Format the moment as a "YYYYMMDD" string.
public function YYYYMMDD(moment as Moment) as String {
    var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);

    return Lang.format("$1$$2$$3$", [
        info.year.format("%04d"),
        info.month.format("%02d"),
        info.day.format("%02d"),
    ]);
}

// Format the moment as a "HHMMSS" string.
public function HHMMSS(moment as Moment) as String {
    var info = Time.Gregorian.info(moment, Time.FORMAT_SHORT);

    return Lang.format("$1$$2$$3$", [
        info.hour.format("%02d"),
        info.min.format("%02d"),
        info.sec.format("%02d"),
    ]);
}
