using Posix;
using Gee;

namespace Usage
{
    public class ProcessRowNew : Gtk.ListBoxRow
    {
        Gtk.Label load_label;
        Gtk.Revealer revealer;
        SubProcessListBox sub_process_list_box;
        string display_name;
        static GLib.List<AppInfo> apps_info;

        public Process process { get; private set; }
        public bool showing_details { get; private set; }
        public bool max_usage { get; private set; }

        public ProcessRowNew(Process process, bool opened)
        {
            if(apps_info == null)
                apps_info = AppInfo.get_all(); //Because it takes too long
            this.process = process;

            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            box.margin = 0;
			var row_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			row_box.margin = 10;
        	load_label = new Gtk.Label(null);
        	load_label.ellipsize = Pango.EllipsizeMode.END;
        	load_label.max_width_chars = 30;

            Gtk.Image icon;
            load_icon_and_name(out icon, out display_name);
            var title_label = new Gtk.Label(display_name);
            row_box.pack_start(icon, false, false, 0);
            row_box.pack_start(title_label, false, true, 5);
            row_box.pack_end(load_label, false, true, 10);
            box.pack_start(row_box, false, true, 0);

            update();
            if(process.sub_processes != null)
            {
                sub_process_list_box = new SubProcessListBox(process);
                revealer = new Gtk.Revealer();
                revealer.add(sub_process_list_box);
                box.pack_end(revealer, false, true, 0);

                if(opened)
                    show_details();
            }
            this.add(box);
            show_all();

            if(opened && process.sub_processes != null)
                show_details();
        }

        public Gtk.Widget on_subrow_created (Object item)
        {
            Process process = (Process) item;
            var row = new SubProcessSubRow(process);
            return row;
        }

        private void load_icon_and_name(out Gtk.Image icon, out string display_name)
        {
            AppInfo app_info = null;
        	foreach (AppInfo info in apps_info)
        	{
        	    string commandline = info.get_commandline();
        	    for (int i = 0; i < commandline.length; i++)
                {
                    if(commandline[i] == ' ')
                        commandline = commandline.substring(0, i);
                }
                commandline = Path.get_basename(commandline);

        	    if(commandline == process.cmdline)
        	        app_info = info;
        	}

            bool not_have_icon = false;
            if(app_info != null)
            {
                display_name = app_info.get_display_name();

        	    if(app_info.get_icon() == null)
                    not_have_icon = true;
                else
                {
                    var icon_theme = new Gtk.IconTheme();
                    var icon_info = icon_theme.lookup_by_gicon_for_scale(app_info.get_icon(), 24, 1, Gtk.IconLookupFlags.FORCE_SIZE);
                    if(icon_info != null)
                    {
                        var pixbuf = icon_info.load_icon();
                        icon = new Gtk.Image.from_pixbuf(pixbuf);
                    }
                    else
                        not_have_icon = true;
                }
        	}
        	else
        	{
        	    display_name = process.cmdline;
        	    not_have_icon = true;
        	}

        	if(not_have_icon)
        	{
        	    icon = new Gtk.Image.from_icon_name("system-run-symbolic", Gtk.IconSize.BUTTON);
        	    icon.width_request = 24;
        	    icon.height_request = 24;
        	}

        	icon.margin_left = 10;
        	icon.margin_right = 10;

        }

        private void update()
        {
            if(process.sub_processes != null)
            {
                string values = "";
                foreach(Process sub_process in process.sub_processes.get_values())
                {
                    if(sub_process.cpu_load >= 1)
                        values += "   " + ((int) sub_process.cpu_load).to_string() + " %";
                }

                load_label.set_label(values);
            }
            else
                load_label.set_label(((int) process.cpu_load).to_string() + " %");

             if(process.cpu_load >= 90)
                 max_usage = true;
             else
                 max_usage = false;
        }

        private void hide_details()
        {
            showing_details = false;
            revealer.set_reveal_child(false);
            load_label.visible = true;
            get_style_context().remove_class("opened");
        }

        private void show_details()
        {
            showing_details = true;
            revealer.set_reveal_child(true);
            load_label.visible = false;
            get_style_context().add_class("opened");

        }

        public void activate()
        {
            if(process.sub_processes != null)
            {
                if(showing_details)
                    hide_details();
                else
                    show_details();
            }
            else
            {
                var dialog = new ProcessDialog(process.pid, display_name);
                dialog.show_all ();
            }
        }
    }
}
