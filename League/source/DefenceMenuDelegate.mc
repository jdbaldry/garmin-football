import Toybox.Lang;
import Toybox.WatchUi;

class DefenceMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId().toString() as String;

        switch (id) {
            case "Tackle":
                EVENTS.add(new DefenceEvent("T"));

                popView(SLIDE_IMMEDIATE);

                break;

            case "Foul":
                EVENTS.add(new DefenceEvent("F"));

                popView(SLIDE_IMMEDIATE);

                break;

            case "Block":
                EVENTS.add(new DefenceEvent("B"));

                popView(SLIDE_IMMEDIATE);

                break;
        }
    }
}
