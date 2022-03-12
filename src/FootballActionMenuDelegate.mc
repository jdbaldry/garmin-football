import Toybox.System;
import Toybox.WatchUi;

class FootballActionMenuDelegate extends WatchUi.MenuInputDelegate {
    private var _team as number;

    public function initialize(team as number) {
        MenuInputDelegate.initialize();
        _team = team;
    }

    public function onMenuItem(action as Symbol) as Void {
        var menu = _team == TEAM_A ? new $.Rez.Menus.A() : new $.Rez.Menus.B();
        switch (action) {
        case :Goal:
            WatchUi.pushView(menu, new $.FootballGoalMenuDelegate(_team, method(:popAdditional)), WatchUi.SLIDE_UP);
            break;
        case :Keeper:
            WatchUi.pushView(menu, new $.FootballKeeperMenuDelegate(_team, method(:popAdditional)), WatchUi.SLIDE_UP);
            break;
        case :OwnGoal:
            WatchUi.pushView(menu, new $.FootballOwnGoalMenuDelegate(_team, method(:popAdditional)), WatchUi.SLIDE_UP);
            break;
        case :YellowCard:
            WatchUi.pushView(menu, new $.FootballCardMenuDelegate(CARD_YELLOW, method(:popAdditional)), WatchUi.SLIDE_UP);
            break;
        case :RedCard:
            WatchUi.pushView(menu, new $.FootballCardMenuDelegate(CARD_RED, method(:popAdditional)), WatchUi.SLIDE_UP);
            break;
        default:
            throw new Lang.InvalidValueException();
        }
    }
}
