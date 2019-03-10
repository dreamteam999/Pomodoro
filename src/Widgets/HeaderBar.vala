public class Pomo.HeaderBar : Gtk.HeaderBar {
    int hbtn_counter = 0;

    construct {
        // set title/subtitle
        set_title("DreamTeam Pomodoro");
        set_subtitle("What will you accomplish today?");
        set_show_close_button(true);        
        // tells default max/restore/close btns to show in headerbar

        // add buttons
        var miscbutton = new Gtk.Button.with_label("New Timer (0)");
        // add icon button -> submenu/popup
        var menu_button = new Gtk.Button.from_icon_name("open-menu", Gtk.IconSize.LARGE_TOOLBAR);

        //connect counter for the click me btn
        miscbutton.clicked.connect (() => {
			// Emitted when the button has been activated:
			miscbutton.label = "I was clicked (%d) times!".printf (++this.hbtn_counter);
		});

        // custom label button creation, styled with the suggested-action css style, aligned to
        miscbutton.get_style_context().add_class("suggested-action");
        miscbutton.valign = Gtk.Align.CENTER;
        pack_start(miscbutton);

        menu_button.valign = Gtk.Align.CENTER;
        pack_end(menu_button);
    }

}
