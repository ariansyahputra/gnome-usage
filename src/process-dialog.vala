using Posix;

namespace Usage
{
	public class ProcessDialog : Gtk.Dialog
	{
	    ProcessDialogHeaderBar headerbar;
    	private pid_t pid;
        GraphBlock processor_graph_block;
        GraphBlock memory_graph_block;
        GraphBlock disk_graph_block;
        GraphBlock downloads_graph_block;
        GraphBlock uploads_graph_block;

    	public ProcessDialog(pid_t pid, string app_name)
    	{
    	    Object(use_header_bar: 1);
    	    set_modal(true);
    	    set_transient_for((GLib.Application.get_default() as Application).get_window());
    	    set_position(Gtk.WindowPosition.CENTER);
    	    set_resizable(false);
    	    this.pid = pid;
    		this.title = app_name;
    		this.border_width = 5;
    		set_default_size (900, 350);
    		create_widgets();
    		//connect_signals();
    	}

    	private void create_widgets()
    	{
    		Gtk.Box content = get_content_area() as Gtk.Box;

            Gtk.Grid grid = new Gtk.Grid();
            grid.margin_top = 20;
            grid.margin_start = 20;
            grid.margin_end = 20;

            processor_graph_block = new GraphBlock(_("Processor"), this.title);
            memory_graph_block = new GraphBlock(_("Memory"), this.title);
            disk_graph_block = new GraphBlock(_("Disk I/O"), this.title);
            downloads_graph_block = new GraphBlock(_("Downloads"), this.title, false);
            uploads_graph_block = new GraphBlock(_("Uploads"), this.title, false);

            grid.attach(processor_graph_block, 0, 0, 1, 1);
            grid.attach(memory_graph_block, 1, 0, 1, 1);
            grid.attach(disk_graph_block, 2, 0, 1, 1);
            grid.attach(downloads_graph_block, 0, 1, 1, 1);
            grid.attach(uploads_graph_block, 1, 1, 1, 1);
            content.add(grid);
            content.show_all();

            //add_button (_("Stop"), Gtk.ResponseType.HELP).get_style_context().add_class ("destructive-action");
            var stop_button = new Gtk.Button.with_label(_("Stop"));
            stop_button.get_style_context().add_class ("destructive-action");

            headerbar = new ProcessDialogHeaderBar(stop_button, pid, this.title);
            set_titlebar(headerbar);

            Timeout.add((GLib.Application.get_default() as Application).settings.list_update_cookie_graphs_UI, update);
            update();
    	}

    	private bool update()
    	{
    	    SystemMonitor monitor = (GLib.Application.get_default() as Application).get_system_monitor();
    	    unowned Process data = monitor.get_process_by_pid(pid);

            ProcessStatus process_status = ProcessStatus.DEAD;
    	    int app_cpu_load = 0;
    	    int app_memory_usage = 0;
    	    int app_download = 0;
    	    int app_upload = 0;

    	    int other_download = 0;
            int other_upload = 0;

    	    if(data != null)
    	    {
    	        app_cpu_load = (int) data.cpu_load;
    	        app_memory_usage = (int) data.mem_usage_percentages;
    	        processor_graph_block.update((int) data.last_processor, app_cpu_load, (int) monitor.x_cpu_load[data.last_processor]-app_cpu_load);

                double download_one_percentage = monitor.net_download / 100;
                if(download_one_percentage != 0)
                {
                    app_download = (int) (data.net_download / download_one_percentage);
                    app_download = int.min(app_download, 100);
                    other_download = 100 - app_download;
                }

                double upload_one_percentage = monitor.net_upload / 100;
                if(upload_one_percentage != 0)
                {
                    app_upload = (int) (data.net_upload / upload_one_percentage);
                    app_upload = int.min(app_upload, 100);
                    other_upload = 100 - app_upload;
                }
                process_status = data.status;
    	    }
    	    else
    	        processor_graph_block.update(-1, 0, (int) monitor.cpu_load);

    	    memory_graph_block.update(-1, app_memory_usage, (int) monitor.ram_usage);
    	    downloads_graph_block.update(-1, app_download, other_download);
            uploads_graph_block.update(-1, app_upload, other_upload);
            headerbar.set_process_state(process_status);
    	    return true;
    	}
    }

    public class ProcessDialogHeaderBar : Gtk.HeaderBar
    {
        private Gtk.Label label;
        private string app_name;
        private Gtk.Button stop_button;

        public ProcessDialogHeaderBar(Gtk.Button stop_button, pid_t pid, string app_name)
        {
            this.app_name = app_name;
            show_close_button = true;
            this.stop_button = stop_button;

            stop_button.clicked.connect(() => {
                kill_process(pid);
                set_process_state(ProcessStatus.DEAD);
            });

            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.hexpand = true;
            box.pack_start(stop_button, false, false);
            label = new Gtk.Label(null);
            label.justify = Gtk.Justification.CENTER;
            box.set_center_widget(label);

            set_custom_title(box);
            show_all();
        }

        private void kill_process(pid_t pid)
        {
             Posix.kill (pid, Posix.SIGKILL);
        }

        public void set_process_state(ProcessStatus status)
        {
            string status_string = "";
            switch(status)
            {
                case ProcessStatus.RUNNING:
                    status_string = _("Running");
                    break;
                case ProcessStatus.SLEEPING:
                    status_string = _("Sleeping");
                    break;
                case ProcessStatus.DEAD:
                    status_string = _("Dead");
                    stop_button.hide();
                    break;
            }

            this.label.set_text("<span font_weight=\"bold\">" + this.app_name + "</span>\n<span font_desc=\"8.0\">" + status_string + "</span>");
            this.label.use_markup = true;
        }
    }
}