public class Event {
    private var _kind as String;

    public function initialize(kind as String) {
        _kind = kind;
    }

    public function kind() as String {
        return _kind;
    }

    public function label() as String {
        return "label() not implemented";
    }

    public function jsonLog() {
        $.jsonLog(["event", "error", "value", "jsonLog() not implemented"]);
    }
}

public class ActionEvent extends Event {
    private var _action as String;

    public function initialize(action as String) {
        Event.initialize("Action");
        _action = action;

        jsonLog();
    }

    public function label() as String {
        return _action;
    }

    public function jsonLog() {
        $.jsonLog(["event", "A", "value", _action]);
    }
}

public class StartedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("started");
    }
}

public class PausedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("paused");
    }
}

public class StoppedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("stopped");
    }
}

public class SavedEvent extends ActionEvent {
    public function initialize() {
        ActionEvent.initialize("saved");
    }
}

public class KeeperEvent extends Event {
    private var _team as String;
    private var _player as String;

    public function initialize(team as String, player as String) {
        Event.initialize("Keeper");
        _team = team;
        _player = player;

        // Skip initial logging of keepers because this is handled by a call
        // back once both have been set.
        if (aKeeper == null || bKeeper == null) {
            return;
        }

        jsonLog();
    }

    public function label() as String {
        return _team.toString() + " " + _player.toString();
    }

    public function jsonLog() {
        $.jsonLog(["event", "K", "team", _team, "player", _player]);
    }
}

public class GoalEvent extends Event {
    private var _team as String;
    private var _player as String;
    private var _keeper as String;

    public function initialize(team as String, player as String, keeper as String) {
        Event.initialize("Goal");
        _team = team;
        _player = player;
        _keeper = keeper;

        jsonLog();
    }

    public function label() as String {
        return _team.toString() + " " + _player.toString();
    }

    public function jsonLog() {
        $.jsonLog(["event", "G", "team", _team, "player", _player, "keeper", _keeper]);
    }
}

public class CaptainEvent extends Event {
    private var _team as String;
    private var _player as String;

    public function initialize(team as String, player as String) {
        Event.initialize("Captain");
        _team = team;
        _player = player;

        jsonLog();
    }

    public function label() as String {
        return _team.toString() + " " + _player.toString();
    }

    public function jsonLog() {
        $.jsonLog(["event", "C", "team", _team, "player", _player]);
    }
}

public class TeamEvent extends Event {
    private var _team;
    private var _players;

    public function initialize(team, players) {
        Event.initialize("Team");
        _team = team;
        _players = players;

        jsonLog();
    }

    public function label() as String {
        return _team.toString() + " " + _players.toString();
    }

    public function jsonLog() {
        $.jsonLog(["event", "T", "team", _team, "players", _players]);
    }
}

public class OwnGoalEvent extends Event {
    private var _team as String;
    private var _player as String;
    private var _keeper as String;

    public function initialize(team as String, player as String, keeper as String) {
        Event.initialize("Own goal");
        _team = team;
        _player = player;
        _keeper = keeper;

        jsonLog();
    }

    public function label() as String {
        return _team.toString() + " " + _player.toString();
    }

    public function jsonLog() {
        $.jsonLog(["event", "OG", "team", _team, "player", _player, "keeper", _keeper]);
    }
}

public class CardEvent extends Event {
    private var _color as String;
    private var _team as String;
    private var _player as String;

    public function initialize(color as String, team as String, player as String) {
        Event.initialize("Card");
        _color = color;
        _team = team;
        _player = player;

        jsonLog();
    }

    public function label() as String {
        return _team.toString() + " " + _player.toString();
    }

    public function jsonLog() {
        $.jsonLog(["event", _color, "team", _team, "player", _player]);
    }
}

public class YellowCardEvent extends CardEvent {
    public function initialize(team, player) {
        CardEvent.initialize("YC", team, player);
    }
}

// TODO: Error: Symbol Not Found Error
// Details: "Could not find symbol '<globals/CardEvent/<>_kind>'"
// When issuing red card.
public class RedCardEvent extends Event {
    public function initialize(team, player) {
        CardEvent.initialize("RC", team, player);
    }
}
