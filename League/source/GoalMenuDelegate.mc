import Toybox.Lang;
import Toybox.WatchUi;

class GoalMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId().toString() as String;

        EVENTS.add(new GoalEvent(id));
        SCORE_A++;

        var menu = new WatchUi.Menu2({ :title => "Assist" });
        var players = split(Application.Properties.getValue("Players"), ",");

        for (var i = 0; i < players.size(); i++) {
            menu.addItem(new MenuItem(players[i], "", players[i], {}));
        }
        WatchUi.pushView(
            menu,
            new AssistMenuDelegate(),
            WatchUi.SLIDE_IMMEDIATE
        );
    }
}
