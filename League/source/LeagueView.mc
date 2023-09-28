import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System;

class LeagueView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {}

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        var now = System.getClockTime();
        dc.drawText(
            dc.getWidth() / 2,
            dc.getFontHeight(Graphics.FONT_LARGE),
            Graphics.FONT_SMALL,
            now.hour.format("%02d") +
                ":" +
                now.min.format("%02d") +
                ":" +
                now.sec.format("%02d"),
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_LARGE,
            SCORE_A + " : " + SCORE_B,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        if (MATCH_STATE != MATCH_NONE && MATCH_STATE != MATCH_STOPPED) {
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

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {}
}
