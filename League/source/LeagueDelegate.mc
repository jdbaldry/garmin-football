import Toybox.ActivityRecording;
import Toybox.Lang;
import Toybox.WatchUi;

enum {
    MATCH_NONE,
    MATCH_RECORDING,
    MATCH_PAUSED,
    MATCH_STOPPED,
}

var MATCH_STATE = MATCH_NONE;
var SESSION as Session?;
var EVENTS as Array<Event> = [];

var SCORE_A = 0;
var SCORE_B = 0;

class LeagueDelegate extends WatchUi.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

    // MATCH
    function onSelect() as Boolean {
        pushView(new Rez.Menus.Activity(), new MatchMenuDelegate(), SLIDE_UP);

        return true;
    }

    // OTHER
    //
    //  SUB ---> OFF[PLAYER] ---> ON[PLAYER]
    // CARD ---> YELLOW[PLAYER]
    //      `-->  RED[PLAYER]
    function onMenu() as Boolean {
        if (MATCH_STATE == MATCH_RECORDING) {
            pushView(new Rez.Menus.Sub(), new SubMenuDelegate(), SLIDE_UP);
        }

        return true;
    }

    // KEEPER
    function onBack() as Boolean {
        if (MATCH_STATE == MATCH_RECORDING) {
            pushView(
                new Rez.Menus.Keeper(),
                new KeeperMenuDelegate(),
                SLIDE_UP
            );
        }

        return true;
    }

    function onKey(evt as KeyEvent) as Boolean {
        if (MATCH_STATE == MATCH_RECORDING) {
            switch (evt.getKey()) {
                // ATTACK
                case KEY_UP:
                    pushView(
                        new Rez.Menus.Attack(),
                        new AttackMenuDelegate(),
                        SLIDE_UP
                    );

                    return true;

                // DEFENCE
                case KEY_DOWN:
                    pushView(
                        new Rez.Menus.Defence(),
                        new DefenceMenuDelegate(),
                        SLIDE_UP
                    );

                    return true;

                default:
                    System.println("Unhandled key: " + evt.getKey());

                    return false;
            }
        }

        return true;
    }
}
