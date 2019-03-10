public class Pomodoro : Gtk.Application { //Pomodoro extends Gtk.Application class
    public static GLib.Settings settings;

    public Pomodoro() {
        Object(application_id: "com.github.DreamTeam999.Pomodoro", flags: ApplicationFlags.FLAGS_NONE);
    }

    static construct {
        settings = new GLib.Settings("com.github.DreamTeam999.Pomodoro");
    }

    protected override void activate() {
        //new window object as defined in Window.vala
        var window = new Pomo.Window(this);
        add_window(window);
    }
}

public static int main(string[] args) {
        // Create new Pomodoro object defined in Pomodoro.vala
        Pomodoro pomo = new Pomodoro();
        return pomo.run(args);
    }

