#GNOME Usage

New GNOME Usage!

## Actual TODO:
- [x] Processor Usage
- [x] Memory usage
- [x] Network usage
- [x] Search in processes 
- [ ] Fix bug with refreshing ProcessListBox - 50% (focus, and click when refresh)
- [ ] Storage view - 75%
- [ ] Power view (Design?)
- [ ] Disk usage (What library we can use?)
- [ ] Data view - 0%

##Installation from RPM
[Download RPM](https://github.com/petr-stety-stetka/gnome-usage/releases/download/v0.3.8/gnome-usage-0.3.8-1.x86_64.rpm)

##Run
In terminal run ```gnome-usage``` command or run GNOME Usage application from app launcher.

##Version
Actual version is 0.4.0

##Dependencies
- [libnetinfo >= 0.3.1](https://github.com/kaegi/netinfo-ffi) 
- libgtop >= 2.34.2

##Compilation from sources:
```
cd gnome-usage
meson build && cd build
ninja-build #or ninja
sudo ninja-build install #sudo ninja install
sudo setcap cap_net_raw,cap_net_admin=eip /usr/local/bin/gnome-usage
```

##License
Code is under GNU GPLv3 license.

##Screenshots:
More screenshots is in screenshots subdirectory (However screenshots may not be current).

![Screenshot](screenshots/screenshot11.png?raw=true )

![Screenshot](screenshots/screenshot10.png?raw=true )

##Design:
<img src="https://raw.githubusercontent.com/gnome-design-team/gnome-mockups/master/usage/usage-wires.png">
