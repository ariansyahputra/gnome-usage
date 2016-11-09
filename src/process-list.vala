using Gee;

namespace Usage
{
    public class ProcessListBox : Gtk.ListBox
    {
        public ProcessListBox()
        {
            set_selection_mode (Gtk.SelectionMode.NONE);
            set_header_func (update_header);
        }

        private void update_header(Gtk.ListBoxRow row, Gtk.ListBoxRow? before_row)
        {
        	if(before_row == null)
			    row.set_header(null);
            else
            {
                var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
				separator.show();
				row.set_header(separator);
			}
        }
    }

    public class ListBox : Gtk.Box
    {
        private Gee.ArrayList<Row> rows;

        HashTable<uint, Row> process_rows_table;

        public ListBox()
        {
            orientation = Gtk.Orientation.VERTICAL;
            rows = new Gee.ArrayList<Row>();
            process_rows_table = new HashTable<uint, Row>(direct_hash, direct_equal);

            Timeout.add((GLib.Application.get_default() as Application).settings.list_update_interval, () =>
            {
                update();
                return true;
            });

        }

        public void update()
        {
            foreach(Row row in rows)
                row.alive = false;

            /*GLib.List<unowned Process> processes = (GLib.Application.get_default() as Application).monitor.get_processes();

            for(int i = 0; i < processes.length(); i++)
            {
                for(int j = i + 1; j < processes.length(); j++)
                {
                    if(processes.nth_data(i).cmdline == processes.nth_data(j).cmdline)
                        stdout.printf(processes.nth_data(i).pid.to_string() + "   " + processes.nth_data(j).pid.to_string() + "   " + processes.nth_data(i).cmdline + "   " + processes.nth_data(j).cmdline + "\n");
                }
            }

            stdout.printf("\n\n\n");*/

            foreach(unowned Process process in (GLib.Application.get_default() as Application).monitor.get_processes())
            {
                if(!(process.pid in process_rows_table))
                {
                    if((int) process.cpu_load > 0)
                    {
                        Row row = new Row(process.pid, (int) process.cpu_load, process.cmdline);
                        rows.add(row);
                        process_rows_table.insert (process.pid, row);
                    }
                }
                else
                {
                    if((int) process.cpu_load > 0)
                    {
                        unowned Row row = process_rows_table[process.pid];
                        row.alive = true;
                        row.set_value((int) process.cpu_load);
                    }
                    else
                    {
                        unowned Row row = process_rows_table[process.pid];
                        rows.remove(row);
                        process_rows_table.remove(process.pid);
                    }
                }
            }

            sort();

            this.forall ((element) => this.remove (element)); //clear box
            for(int i = 0; i < rows.size; i++)
            {
                if(rows[i].alive)
                {
                    this.add(rows[i]);
                }
                else
                {
                    process_rows_table.remove(rows[i].get_pid());
                    rows.remove(rows[i]);
                }
            }
        }

        public void sort()
        {
            rows.sort((a, b) => {
                return(b as Row).get_value() - ( a as Row).get_value();
            });
        }
    }

    public class ProcessDetailListBoxRow : Gtk.ListBoxRow
    {
		private Gtk.Image icon;
        private Gtk.Label title_label;
        private Gtk.Label load_label;

        public int sort_id;

        public bool is_headline { get; private set; }

        public ProcessDetailListBoxRow(string title, int load)
        {
            set_can_focus(true);
            this.get_style_context().add_class("processDetailListBoxRow");
			var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			box.margin = 12;
        	title_label = new Gtk.Label(title);
        	load_label = new Gtk.Label(load.to_string() + " %");
        	icon = new Gtk.Image.from_icon_name("system-run-symbolic", Gtk.IconSize.BUTTON);

            box.pack_start(icon, false, false, 10);
            box.pack_start(title_label, false, true, 5);
            box.pack_end(load_label, false, true, 10);

            add(box);
            show_all();
        }
    }
}
