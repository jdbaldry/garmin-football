import Toybox.System;
import Toybox.WatchUi;

class FootballKeeperMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _team as Number;
    private var _callback as Method;

    public function initialize(team as number, callback as Method?) {
        MenuInputDelegate.initialize();
        _team = team;
        _callback = callback;
    }

    private function logKeeper(keeper as Symbol) as Void {
        jsonLog(["event", "K", "team", _team, "player", keeper]);
    }

    public function onMenuItem(keeper as Symbol) as Void {
        // Log keeper in the middle of a match.
        // Initial keepers are logged at the start of an activity.
        if ((aKeeper != null) && (bKeeper != null)) {
            logKeeper(keeper);
        }
        switch (_team) {
        case TEAM_A:
            aKeeper = keeper;
            break;
        case TEAM_B:
            bKeeper = keeper;
            break;
        default:
            throw new Lang.InvalidValueException(_team);
        }
        if (_callback != null) {
            _callback.invoke();
        }
    }
}
