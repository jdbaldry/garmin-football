import Toybox.Lang;
import Toybox.WatchUi;

class SubMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId().toString() as String;

        var menu = new WatchUi.Menu2({ :title => "Assist" });
        var players = split(Application.Properties.getValue("Players"), ",");

        for (var i = 0; i < players.size(); i++) {
            menu.addItem(new MenuItem(players[i], "", players[i], {}));
        }

        switch (id) {
            case "In":
                WatchUi.pushView(
                    menu,
                    new InMenuDelegate(),
                    WatchUi.SLIDE_IMMEDIATE
                );

                break;

            case "Out":
                WatchUi.pushView(
                    menu,
                    new OutMenuDelegate(),
                    WatchUi.SLIDE_IMMEDIATE
                );

                break;
        }
    }
}
