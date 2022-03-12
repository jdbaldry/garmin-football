import Toybox.Activity;
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

// Team A variables.
public var aScore as Number = 0;
public var aKeeper as Symbol? = null;
// Team B variables.
public var bScore as Number = 0;
public var bKeeper as Symbol? = null;


// popView only if both keepers are set.
// Used as a callback from the transient keeper menu that
// is triggered by starting an activity.
public function popViewIfKeepersAreSet() {
    if ((aKeeper != null) && (bKeeper != null)) {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
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

public function timerTimeToString(timerTime as Number) as String {
    var options = {:seconds => (timerTime * 0.001).toNumber()};
    var timerValue = Time.Gregorian.duration(options).value();
    var seconds = timerValue % 60;
    var minutes = timerValue / 60;

    return minutes.format("%02d") + ":" + seconds.format("%02d");
}

public function log(string as String) as Void {
        var info = Activity.getActivityInfo();
        var timerTime = info.timerTime;
        if (timerTime != null) {
            System.println(timerTimeToString(timerTime) + " " + string);
        } else {
            System.println("00:00 " + string);
        }
}

class FootballDelegate extends WatchUi.BehaviorDelegate {
    private var _parentView as InputView;

    public function initialize(view as InputView) {
        BehaviorDelegate.initialize();
        _parentView = view;
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
