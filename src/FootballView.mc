import Toybox.Activity;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class FootballView extends WatchUi.View {
    private var timer as Timer;

    public function initialize() {
        View.initialize();
        timer = new Timer.Timer();
        timer.start(method(:onTick), 1000, true);
    }

    public function onTick() {
        WatchUi.requestUpdate();
    }

    public function onHide() as Void {}

    public function onShow() as Void {}

    public function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, 0, Graphics.FONT_LARGE, "Football", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(dc.getWidth() / 2, (dc.getHeight() / 2), Graphics.FONT_LARGE, aScore + " : " + bScore, Graphics.TEXT_JUSTIFY_CENTER);

        var info = Activity.getActivityInfo();
        var timerTime = info.timerTime;
        if (timerTime != null) {
            dc.drawText(
                dc.getWidth() / 2,
                dc.getHeight() - dc.getFontHeight(Graphics.FONT_SMALL),
                Graphics.FONT_NUMBER_THAI_HOT | Graphics.FONT_SMALL,
                timerTimeToString(timerTime),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }
}
