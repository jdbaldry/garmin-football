using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

class FootballView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onHide() {}

    function onLayout(dc as Dc) as Void {}

    function onShow() as Void {
        System.println("Hello, World!\n");
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var dy = dc.getFontHeight(Graphics.FONT_SMALL);
        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;
        y -= (4 * dy) / 2;

        dc.drawText(x, y, Graphics.FONT_SMALL, "Hello, World!", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
