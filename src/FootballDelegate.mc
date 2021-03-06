import Toybox.Activity;
import Toybox.ActivityRecording;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

public enum {
    TEAM_A,
    TEAM_B,
}

public enum {
    CARD_YELLOW,
    CARD_RED,
}

public enum {
    ACTION_GOAL,
    ACTION_KEEPER,
    ACTION_OWN_GOAL,
    ACTION_CARD,
}

public enum {
    ACTIVITY_NONE,
    ACTIVITY_RECORDING,
    ACTIVITY_PAUSED,
    ACTIVITY_STOPPED
}

// Activity session.
public var activityState = ACTIVITY_NONE;
public var session as Session?;

public var players = {
    "Archie"=>:Archie,
    "Baldry"=>:Baldry,
    "Barge"=>:Barge,
    "Ben"=>:Ben,
    "Bloor"=>:Bloor,
    "Chris"=>:Chris,
    "Connor"=>:Connor,
    "Dave"=>:Dave,
    "Gwin"=>:Gwin,
    "Jack"=>:Jack,
    "Jake"=>:Jake,
    "Jim"=>:Jim,
    "Lee"=>:Lee,
    "Leigh"=>:Leigh,
    "Liam"=>:Liam,
    "MG"=>:MG,
    "Mabel"=>:Mabel,
    "Mitch"=>:Mitch,
    "Niall"=>:Niall,
    "Nobby"=>:Nobby,
    "Notley"=>:Notley,
    "Olly"=>:Olly,
    "Other"=>:Other,
    "Q"=>:Q,
    "Shirley"=>:Shirley,
    "Tom"=>:Tom,
    "TC"=>:TC,
    "Wardale"=>:Wardale,
    "Wrighty"=>:Wrighty,
};
// Team A variables.
public var aMenu as WatchUi.Menu = new WatchUi.Menu();
public var aTeam = [
                    "Liam",
                    "Q",
                    "Baldry",
                    "Archie",
                    "Notley",
                    ];
public var aScore as Number = 0;
public var aKeeper as Symbol? = null;
// Team B variables.
public var bMenu as WatchUi.Menu = new WatchUi.Menu();
public var bTeam = [
                    "Mitch",
                    "Wardale",
                    "Ben",
                    "Gwin",
                    "Other",
                    ];
public var bScore as Number = 0;
public var bKeeper as Symbol? = null;

// Start an activity and pop the view back to the football app
// only if both keepers are set.
// Used as a callback from the transient keeper menu that
// is triggered by choosing to start an activity.
public function startActivityIfKeepersAreSet() {
    if ((aKeeper != null) && (bKeeper != null)) {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
    if (session == null) {
        session = ActivityRecording.createSession({
                :name=>"Football",
                    :sport=>ActivityRecording.SPORT_GENERIC,
                    :subSport=>ActivityRecording.SUB_SPORT_GENERIC
                    });
    }
    if (session.isRecording() == false) {
        session.start();
        activityState = ACTIVITY_RECORDING;
        jsonLog(["event", "A", "value", "started"]);
        jsonLog(["event", "C", "team", TEAM_A, "player", aTeam[0]]);
        jsonLog(["event", "C", "team", TEAM_B, "player", bTeam[0]]);
        jsonLog(["event", "T", "team", TEAM_A, "players", aTeam]);
        jsonLog(["event", "T", "team", TEAM_B, "players", bTeam]);
    }
}

// Pop an additional view.
// Used as a callback from transient menus.
public function popAdditional() {
    WatchUi.popView(WatchUi.SLIDE_DOWN);
}

// Quit the application.
public function quit() {
    System.exit();
}

public function join(arr as Array<String>, str as String) as String {
    var joined as String = "";
    for (var i = 0; i < arr.size(); i++) {
        if (i != 0) {
            joined += str;
        }
        joined += arr[i];
    }
    return joined;
}

public function timerTimeToString(timerTime as Number) as String {
    var options = {:seconds => (timerTime * 0.001).toNumber()};
    var timerValue = Time.Gregorian.duration(options).value();
    var seconds = timerValue % 60;
    var minutes = timerValue / 60;

    return minutes.format("%02d") + ":" + seconds.format("%02d");
}

// Return UTC time in RFC 3339 format with second level precision.
// Example: 2006-08-14 02:34:56
public function rfc3339(moment as Moment) as String {
    var info = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    return Lang.format("$1$-$2$-$3$ $4$:$5$:$6$",
                       [info.year.format("%04d"), info.month.format("%02d"), info.day.format("%02d"), info.hour.format("%02d"), info.min.format("%02d"), info.sec.format("%02d")]);
}

public function toJson(anything) as String {
    switch (anything) {
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
            throw new Lang.InvalidValueException();
        }
    }
}

public function jsonLog(pairs as Array<String>) as Void {
    // {"ts": "<timestamp>"
    var line = "{\"ts\": \"" + rfc3339(Time.now()) + "\"";

    for (var i = 0; i < pairs.size(); i += 2) {
        // , "<key>":
        var key = pairs[i];
        line += ", ";
        line += toJson(key);
        line += ":";

        if ((i + 1) < pairs.size()) {
            var value = pairs[i+1];
            line += " " + toJson(value);
        } else {
            // "MISSING"
            line += " \"MISSING\"";
        }
    }
    line += "}";
    System.println(line);
}

public function log(string as String) as Void {
    System.println(rfc3339(Time.now()) + " " + string);
}

class FootballDelegate extends WatchUi.BehaviorDelegate {
    private var _parentView as InputView;

    public function initialize(view as InputView) {
        BehaviorDelegate.initialize();
        _parentView = view;
        for (var i = 0; i < aTeam.size(); i++) {
            aMenu.addItem(aTeam[i], players[aTeam[i]]);
        }
        for (var i = 0; i < bTeam.size(); i++) {
            bMenu.addItem(bTeam[i], players[bTeam[i]]);
        }
    }

    public function onSelect() as Boolean {
        var activityMenu = new WatchUi.Menu();
        activityMenu.setTitle("Activity");
        switch (activityState) {
        case ACTIVITY_NONE:
            activityMenu.addItem("Start", :Start);
            break;
        case ACTIVITY_RECORDING:
            activityMenu.addItem("Pause", :Pause);
            activityMenu.addItem("Stop", :Stop);
            break;
        case ACTIVITY_PAUSED:
            activityMenu.addItem("Resume", :Start);
            activityMenu.addItem("Stop", :Stop);
            break;
        case ACTIVITY_STOPPED:
            activityMenu.addItem("Restart", :Start);
            break;
        default:
            throw new Lang.InvalidValueException();
        }
        WatchUi.pushView(activityMenu, new $.FootballActivityMenuDelegate(null), WatchUi.SLIDE_UP);
        return true;
    }

    public function onBack() as Boolean {
        WatchUi.pushView(new $.Rez.Menus.QuitMenu(), new $.FootballQuitMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    //! Handle a physical button being pressed
    //! @param evt The key event that occurred
    //! @return true if handled, false otherwise
    public function onKey(evt as KeyEvent) as Boolean {
        var key = evt.getKey();
        if ((key == KEY_UP) && (activityState == ACTIVITY_RECORDING)) {
            WatchUi.pushView(new $.Rez.Menus.ActionMenu(), new $.FootballActionMenuDelegate(TEAM_A), WatchUi.SLIDE_UP);
        } else if ((key == KEY_DOWN) && (activityState == ACTIVITY_RECORDING)) {
            WatchUi.pushView(new $.Rez.Menus.ActionMenu(), new $.FootballActionMenuDelegate(TEAM_B), WatchUi.SLIDE_UP);
        } else {
            return false;
        }
        return true;
    }
}
