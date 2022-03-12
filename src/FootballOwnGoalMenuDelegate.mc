import Toybox.System;
import Toybox.WatchUi;

class FootballOwnGoalMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _team as Number;
    private var _callback as Method?;

    public function initialize(team as Number, callback as Method?) {
        MenuInputDelegate.initialize();
        _team = team;
        _callback = callback;
    }

    private function logGoal(scorer as Symbol, keeper as Symbol?) as Void {
        if (keeper != null) {
            log("Own goal scored by " + scorer.toString() + " against " + keeper.toString());
        } else {
            log("Own goal scored by " + scorer.toString());
        }
    }

    public function onMenuItem(scorer as Symbol) as Void {
        switch (_team) {
        case TEAM_A:
            logGoal(scorer, aKeeper);
            bScore++;
            break;
        case TEAM_B:
            logGoal(scorer, bKeeper);
            aScore++;
            break;
        default:
            throw new Lang.InvalidValueException();
        }

        if (_callback != null) {
            _callback.invoke();
        }
    }
}
