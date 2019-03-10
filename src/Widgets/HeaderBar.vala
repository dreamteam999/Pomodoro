public class Pomo.HeaderBar : Gtk.HeaderBar {
    int hbtn_counter = 0;

    construct {
        // set title/subtitle
        set_title("DreamTeam Pomodoro");
        set_subtitle("What will you accomplish today?");
        set_show_close_button(true);        
        // tells default max/restore/close btns to show in headerbar

        // add miscbutton
        var miscbutton = new Gtk.Button.with_label("New Timer (0)");
        // add icon button -> submenu/popup
        var menu_button = new Gtk.Button.from_icon_name("open-menu", Gtk.IconSize.LARGE_TOOLBAR);
        //style the HBbuttons
        // custom label creation, styled with the suggested-action css style
        miscbutton.get_style_context().add_class("suggested-action");
        miscbutton.valign = Gtk.Align.CENTER; //center in HB
        pack_start(miscbutton); //push to left of HB

        menu_button.valign = Gtk.Align.CENTER;
        pack_end(menu_button); //push to right of HB

        //connect to miscbutton's "clicked" signal
        miscbutton.clicked.connect (() => {
			// Emitted when the button has been activated:
			miscbutton.label = "I was clicked (%d) times!".printf (++this.hbtn_counter);
		});

    }

}
