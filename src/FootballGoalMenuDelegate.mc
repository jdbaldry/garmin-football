import Toybox.System;
import Toybox.WatchUi;

class FootballGoalMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _team as Number;
    private var _callback as Method?;

    public function initialize(team as Number, callback as Method?) {
        MenuInputDelegate.initialize();
        _team = team;
        _callback = callback;
    }

    public function onMenuItem(scorer as Symbol) as Void {
        switch (_team) {
        case TEAM_A:
            events.add(new GoalEvent(_team, scorer, bKeeper));
            aScore++;
            break;
        case TEAM_B:
            events.add(new GoalEvent(_team, scorer, aKeeper));
            bScore++;
            break;
        default:
            throw new Lang.InvalidValueException();
        }

        if (_callback != null) {
            _callback.invoke();
        }
    }
}
