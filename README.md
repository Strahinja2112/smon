# Smon

A system monitor plugin for the Omarchy bar and sidebar. Plugin ID: `archy.smon`.

The vertical sidebar stacks CPU temperature below the CPU icon and used memory below the RAM icon. Small gauges beside the icons show load, with smaller readings, extra vertical padding, and a divider before RAM. Clicking the widget opens a detailed system panel.

## Features

- CPU load, temperature, clock speed, and history.
- RAM usage, swap, and supported memory compression statistics.
- GPU metrics when supported by the hardware and driver.
- Storage usage and top processes in the system panel.
- Theme colors, configurable item order, and panel sections.
- Horizontal bar support with icons, compact, full, and label modes.

## Requirements

An Omarchy installation with Quickshell shell plugin support. Hardware readings use Linux `/proc` and `/sys`; available metrics depend on your sensors and drivers. NVIDIA metrics require `nvidia-smi`. The process panel requires Python 3. Storage discovery uses `findmnt` and `lsblk`.

## Install

```bash
omarchy plugin add https://github.com/Strahinja2112/smon.git --enable
```

For a vertical sidebar, place Smon immediately after the workspace widget:

```bash
omarchy bar move archy.smon --section left --index 1
```

If the plugin does not appear, restart the shell:

```bash
omarchy restart shell
```

## Controls

- Left click: open the system panel.
- Right click: cycle display modes.
- Middle click: refresh readings.
- Hover: view hardware details.

The panel's gear settings control item order, visibility, dials, and sections. Temperature appears when a supported sensor is available. Memory readings use binary units (GiB); the compact sidebar suffix is `G`.

## Settings

Examples:

```bash
omarchy bar set archy.smon mode compact
omarchy bar set archy.smon showGauges true --json
omarchy bar set archy.smon showGpu false --json
omarchy bar set archy.smon fahrenheit true --json
```

The full settings schema is in [manifest.json](manifest.json). Display modes mainly affect the horizontal bar; the vertical sidebar uses the stacked layout.

## Update

```bash
omarchy plugin update archy.smon
```

## Local development

```bash
git clone https://github.com/Strahinja2112/smon.git
cd smon
omarchy plugin validate .
```

To install local changes, copy the runtime files into the plugin directory:

```bash
mkdir -p ~/.config/omarchy/plugins/archy.smon
cp manifest.json Widget.qml SystemPanel.qml Service.qml Model.js Gauge.qml Dial.qml hw-probe disk-probe proc_top.py ~/.config/omarchy/plugins/archy.smon/
omarchy restart shell
```

## Process information

The top-processes panel can show Chromium tab domain hints. Where Linux permits it, the inherited helper reads browser process memory to infer these hints. Hints may be inaccurate. Process labels and CPU snapshots are cached in a private file in the runtime directory. Hide the Top processes section to stop its worker.

Plugins run with your user permissions inside the Omarchy shell. Review code before installing. The optional `clickCommand` setting executes a shell command when clicked.

## Credits and license

Smon adapts [zoltanf/omarchy-hw-monitor](https://github.com/zoltanf/omarchy-hw-monitor), which builds on [meviusisback/omarchy-hw-monitor](https://github.com/meviusisback/omarchy-hw-monitor) and [Edgar Silva's original project](https://github.com/edgarsilva/omarchy-hw-monitor).

The sidebar layout and plugin identity are customized here. Existing `preview*.png` files show upstream designs, not the current Smon sidebar.

[MIT license](LICENSE). Original copyright notices are retained.
