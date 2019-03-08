public class Pomodoro : Gtk.Application {

    public Pomodoro() {
        Object(application_id: "com.github.DreamTeam.Pomodoro", flags: ApplicationFlags.FLAGS_NONE);
    }

    protected override void activate() {
        var window = new Pomo.Window(this);

        add_window(window);

    }

}
