import Toybox.Lang;
import Toybox.WatchUi;

class AttackMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId().toString() as String;

        switch (id) {
            // TODO: Add player and assist player.
            case "Goal":
                var menu = new WatchUi.Menu2({ :title => "Goal" });
                var players = split(
                    Application.Properties.getValue("Players"),
                    ","
                );

                for (var i = 0; i < players.size(); i++) {
                    menu.addItem(new MenuItem(players[i], "", players[i], {}));
                }
                WatchUi.pushView(
                    menu,
                    new GoalMenuDelegate(),
                    WatchUi.SLIDE_IMMEDIATE
                );

                break;

            case "Miss":
                EVENTS.add(new AttackEvent("M"));

                popView(SLIDE_IMMEDIATE);

                break;

            case "Save":
                EVENTS.add(new AttackEvent("S"));

                popView(SLIDE_IMMEDIATE);

                break;
        }
    }
}
