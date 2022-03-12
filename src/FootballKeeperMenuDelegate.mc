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
        log(join(["K", keeper.toString()], ","));
    }

    public function onMenuItem(keeper as Symbol) as Void {
        switch (_team) {
        case TEAM_A:
            logKeeper(keeper);
            aKeeper = keeper;
            break;
        case TEAM_B:
            logKeeper(keeper);
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
