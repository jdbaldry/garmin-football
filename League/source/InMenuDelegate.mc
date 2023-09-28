import Toybox.Lang;
import Toybox.WatchUi;

class InMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as MenuItem) as Void {
        var id = item.getId().toString() as String;

        EVENTS.add(new InEvent(id));

        popView(SLIDE_IMMEDIATE);
    }
}
