import Toybox.Lang;
import Toybox.WatchUi;

class KeeperMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId().toString() as String;

        switch (id) {
            case "Save":
                EVENTS.add(new KeeperEvent("S"));

                popView(SLIDE_IMMEDIATE);

                break;

            case "Concede":
                SCORE_B++;
                EVENTS.add(new KeeperEvent("C"));

                popView(SLIDE_IMMEDIATE);

                break;

            case "Pass":
                EVENTS.add(new KeeperEvent("P"));

                popView(SLIDE_IMMEDIATE);

                break;
        }
    }
}
