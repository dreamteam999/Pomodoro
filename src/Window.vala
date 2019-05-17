namespace Pomodoro {

public class Window : Gtk.ApplicationWindow {
    //public static GLib.Settings settings;
    private const string LIGHT_MODE = "display-brightness-symbolic";
    private const string DARK_MODE = "weather-clear-night-symbolic";
    //bool darkmode;
    public static double timeelapsed;
    public static double timelim = 10; //minutes

    public enum Mode {
        RUNNING,
        STOPPED,
        PAUSED,
        BREAK
    }

    public Mode mode { get; private set; default = Mode.STOPPED; }

    public Window(Application app) {
        // TODO: Look into requesting position to stop window from jumping on open
        Object (application: app, //app instance
                height_request: 600,
                width_request: 800); //eliminate need to set size every start
        // TC: Has side effects, such as making the above dimens the min size.
        // I don't consider this bad, in case we want a default window size
    }

    static Gtk.Label minuteslabel; //we declare these globally Pomodoro namespace
    static Gtk.Label secondslabel; //so that we can access them in member functions
    Gtk.Button timerbutton;
    private GLib.Timer timer = new GLib.Timer();

    construct {
        border_width = 10;
        delete_event.connect(e => { //connect before_destroy() to window terminator
            //return false;
            return before_destroy();
        });

        /*  Start Headerbar */
        timerbutton = new Gtk.Button.with_label("Start Timer");
        timerbutton.get_style_context().add_class("suggested-action");
        timerbutton.valign = Gtk.Align.CENTER; //center in HB

        /* Settings Menu       */
        /* add settings cog... */
        var menu_button = new Gtk.MenuButton(); //autoconnects a menu
        menu_button.image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        menu_button.tooltip_text = "Menu";
        // ...and it's menu
        var menu_popover = new Gtk.Popover (menu_button);
        menu_button.popover = menu_popover;

        //pomodoro length buttons
        var pom_label = new Gtk.Label("Pomodoro Lengths");
        var tf_button = new Gtk.Button.with_label ("25");
        tf_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl>2"},
            ("25min Pomodoro"));
        var to_button = new Gtk.Button.with_label ("30");
        to_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl>3"},
            ("30min Pomodoro"));
        var ff_button = new Gtk.Button.with_label ("45");
        ff_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl>4"},
            ("45min Pomodoro"));

        var pomodoro_grid = new Gtk.Grid();
        pomodoro_grid.column_homogeneous = true;
        pomodoro_grid.hexpand = true;
        pomodoro_grid.margin = 12;

        pomodoro_grid.attach (pom_label, 0, 0, 3);
        pomodoro_grid.attach (tf_button, 0, 1); // new rows are created automatically
        pomodoro_grid.attach (to_button, 1, 1);
        pomodoro_grid.attach (ff_button, 2, 1);
        // break length buttons
        var break_label = new Gtk.Label("Break Lengths");
        var tfb_button = new Gtk.Button.with_label ("3/15");
        tfb_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl><Shift>2"},
            ("3 and 15min Breaks"));
        var ftb_button = new Gtk.Button.with_label ("5/25");
        ftb_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl><Shift>3"},
            ("5 and 25min Breaks"));
        var ttb_button = new Gtk.Button.with_label ("10/30");
        ttb_button.tooltip_markup = Granite.markup_accel_tooltip (
            {"<Ctrl><Shift>4"},
            ("10 and 30min Breaks"));

        var break_grid = new Gtk.Grid();
        break_grid.column_homogeneous = true;
        break_grid.hexpand = true;
        break_grid.margin = 12;

        break_grid.attach(break_label, 0, 0, 3);
        break_grid.attach(tfb_button, 0, 1);
        break_grid.attach(ftb_button, 1, 1);
        break_grid.attach(ttb_button, 2, 1);

        var reset_label = new Gtk.Label ("Reset Pomodoros");
        reset_label.halign = Gtk.Align.START;
        reset_label.hexpand = true;
        reset_label.margin_start = 3;
        reset_label.margin_end = 3;

        var quit_button = new Gtk.Button ();
        // makes button flat with menus css
        quit_button.get_style_context ().add_class (Gtk.STYLE_CLASS_MENUITEM);

        var reset_grid = new Gtk.Grid();
        reset_grid.column_homogeneous = true;
        reset_grid.hexpand = true;
        reset_grid.margin = 6;

        reset_grid.add (reset_label);
        quit_button.add (reset_grid);

        //popover separators
        var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator.margin_top = separator.margin_bottom = 3;
        var separator2 = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
        separator2.margin_top = separator2.margin_bottom = 3;

        var menu_grid = new Gtk.Grid();
        menu_grid.margin_bottom = 3;
        menu_grid.width_request = 200;

        menu_grid.attach (pomodoro_grid, 0, 0); // connect all grids to the popover
        menu_grid.attach (separator, 0, 1); // col, row
        menu_grid.attach (break_grid, 0, 2);
        menu_grid.attach (separator2, 0, 3);
        menu_grid.attach (quit_button, 0, 4);
        menu_grid.show_all();

        menu_popover.add (menu_grid);
        /* End Settings Menu */

        //light/dark Granite.ModeSwitch
        //https://github.com/elementary/granite/blob/master/lib/Widgets/ModeSwitch.vala
        var gtk_settings = Gtk.Settings.get_default ();
        var mode_switch = new Granite.ModeSwitch.from_icon_name (LIGHT_MODE, DARK_MODE);
        mode_switch.primary_icon_tooltip_text = "Light Mode";
        mode_switch.secondary_icon_tooltip_text = "Dark Mode";
        mode_switch.valign = Gtk.Align.CENTER;
        mode_switch.bind_property ("active", gtk_settings,
                         "gtk_application_prefer_dark_theme"); //bind to gtk settings
        Application.settings.bind("dark-mode", mode_switch,
                         "active", SettingsBindFlags.DEFAULT); //bind to gsettings

        //initialize the headerbar
        var headerbar = new Gtk.HeaderBar ();
        headerbar.set_title("DreamTeam Pomodoro");
        headerbar.set_subtitle("What will you accomplish today?");
        headerbar.show_close_button = true;
        headerbar.pack_start(timerbutton); //push to  left of HB
        headerbar.pack_end (menu_button); //push to right of HB
        headerbar.pack_end (mode_switch);
        set_titlebar (headerbar); //activate the headerbar
        /* End Headerbar */
        /* Start MainWindow */
        minuteslabel = new Gtk.Label("00:");
        secondslabel = new Gtk.Label("00");
        minuteslabel.get_style_context ().add_class ("h1");
        secondslabel.get_style_context ().add_class ("h1");

        var indicator1 = new Gtk.Image();
        indicator1.set_from_icon_name("edit-flag", Gtk.IconSize.LARGE_TOOLBAR);
        var indicator2 = new Gtk.Image();
        indicator2.set_from_icon_name("edit-flag", Gtk.IconSize.LARGE_TOOLBAR);
        var indicator3 = new Gtk.Image();
        indicator3.set_from_icon_name("edit-flag", Gtk.IconSize.LARGE_TOOLBAR);
        var indicator4 = new Gtk.Image();
        indicator4.set_from_icon_name("edit-flag", Gtk.IconSize.LARGE_TOOLBAR);

        var indicator_grid = new Gtk.Grid();
        indicator_grid.column_homogeneous = true;
        indicator_grid.hexpand = true;

        indicator_grid.attach(indicator1, 0, 0, 1, 1); //col, row
        indicator_grid.attach(indicator2, 1, 0, 1, 1);
        indicator_grid.attach(indicator3, 2, 0, 1, 1);
        indicator_grid.attach(indicator4, 3, 0, 1, 1);

        var pomogrid = new Gtk.Grid ();
        pomogrid.attach(minuteslabel, 0, 0, 1, 1); //col, row, colW, rowW
        pomogrid.attach(secondslabel, 1, 0, 1, 1);

        var window_grid = new Gtk.Grid();
        window_grid.attach(pomogrid, 0, 0);
        window_grid.attach(indicator_grid, 0, 1);
        window_grid.show_all();
        add(window_grid); //commit the grid of grids that was constructed

        /*          BUTTON EVENTS                   */
        /* connect to timerbutton's "clicked" signal */
        timerbutton.clicked.connect (() => {
			// Emitted when the button has been activated:
            startTimer();
		});
        /* Pomodoro Lengths */
        tf_button.clicked.connect(() => {
            Application.settings.set_int("pomodoro-length", 1500); //25min - sec
        });
        to_button.clicked.connect(() => {
            Application.settings.set_int("pomodoro-length", 1800); //30min - sec
        });
        ff_button.clicked.connect(() => {
            Application.settings.set_int("pomodoro-length", 2700); //45min - sec
        });
        /* Break Lengths */
        tfb_button.clicked.connect(() => {
            Application.settings.set_int("break-length", 2700); //45min - sec
        });
        ftb_button.clicked.connect(() => {
            Application.settings.set_int("break-length", 2700); //45min - sec
        });
        ttb_button.clicked.connect(() => {
            Application.settings.set_int("break-length", 2700); //45min - sec
        });

        int posx = Application.settings.get_int ("position-x");
        int posy = Application.settings.get_int ("position-y");
        int winx = Application.settings.get_int ("window-width");
        int winy = Application.settings.get_int ("window-height");

        if (posx != -1 ||  posy != -1)
            this.move(posx, posy);
        if (winx != -1 || winy != -1)
            this.resize (winx, winy);
        //Recursively shows widgets, and any child widgets (if widget is container) 
        show_all();
    } //construct

    public void startTimer() {
        switch(mode) {
        case Mode.STOPPED:
            mode = Mode.RUNNING;
            timerbutton.label = "Stop Timer";
            timerbutton.get_style_context().add_class("destructive-action");
            timer.start();
            GLib.Timeout.add_seconds(1, timeLeft); //its more clear passing my own function
            //this will run timeLeft every 1s until !timeLeft
            break;
        case Mode.RUNNING:
            mode = Mode.PAUSED;
            timer.stop();
            updateTimer(timeelapsed);
            timerbutton.label = "Resume Timer";
            timerbutton.get_style_context().remove_class("destructive-action");
            break;
        case Mode.PAUSED:
            if(timeLeft()) {
                mode = Mode.RUNNING;
                timelim -= timer.elapsed();
                timerbutton.label = "Stop Timer";
                timerbutton.get_style_context().add_class("destructive-action");
                timer.start();
                GLib.Timeout.add_seconds(1, timeLeft);
                break;
            }
            mode = Mode.STOPPED;
            break;
        case Mode.BREAK:
            break; //probably need an error case for the timer not existing
        default:
            break;
        }
        //TODO: if pomcount >=4 Mode.STOPPED else Mode.BREAK;
        //TODO: set timelim to appropriate value
    }

    public bool timeLeft() {
        timeelapsed = Math.ceil(timelim - timer.elapsed());
        //db: stdout.printf("p-te: %f", timeelapsed);
        if(timeelapsed < 0) { //< lets the timer hit 0
            mode = Mode.STOPPED;
            timerbutton.label = "Break Time";
            timerbutton.get_style_context().remove_class("destructive-action");
            timelim = Application.settings.get_int("pomodoro-length");
            return false; } //call alarm
        updateTimer(timeelapsed);
        return true;
    }

    public void updateTimer(double timeelapsed) {
        double t = Math.ceil(timeelapsed);
        //db: stdout.printf("tlim: %d, te %d, t:%d\n", (int)timelim, (int)timeelapsed, (int)t);
        int m;
        int s;
        double r;
        time_to_ms(t, out m, out s, out r);
        //db: stdout.printf("time-ms: %d\n", (int)t);
        updateTimerLabel(m, s);
    }

    public void updateTimerLabel(int m, int s) {
        string tm = "%02d:".printf(m); //mod strings to make
        string ts = "%02d".printf(s); // time format look nicer
        minuteslabel.set_label(tm);
        secondslabel.set_label(ts);
    }
    //Derives time in 60's, modfied from gnome clocks
    public void time_to_ms (double t, out int m, out int s, out double remainder) {
        m = (int) t / 60;
        t = t % 60;
        s = (int) t;
        remainder = t - s;
    }

    // This function returns false by default, and has no default actions
    // Here, we hi-jack the function to add saving the window dimen/location to gsettings
    // when the function return false and closes the program as requested
    public bool before_destroy () {
        int width, height, x, y;
        get_size(out width, out height);
        get_position(out x, out y);
        Pomodoro.Application.settings.set_int("position-x", x);
        Pomodoro.Application.settings.set_int("position-y", y);
        Pomodoro.Application.settings.set_int("window-width", width);
        Pomodoro.Application.settings.set_int("window-height", height);
        if(Application.settings.get_boolean("dark-mode")) {
            Application.settings.set_boolean("dark-mode", true);
        } else {
            Application.settings.set_boolean("dark-mode", false); 
        }
        return false;
    }
}
} //namespace Pomodoro
