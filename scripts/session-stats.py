#!/usr/bin/python3
"""Count system processes and distinct apps with open Hyprland windows."""
import json
import os
import subprocess


def main():
    processes = sum(entry.name.isdecimal() for entry in os.scandir('/proc'))
    apps = None
    try:
        result = subprocess.run(['hyprctl', 'clients', '-j'], capture_output=True,
                                timeout=2, check=True)
        if len(result.stdout) <= 1024 * 1024:
            clients = json.loads(result.stdout)
            if isinstance(clients, list):
                apps = len({client.get('class') or client.get('initialClass')
                            for client in clients if isinstance(client, dict)
                            and (client.get('class') or client.get('initialClass'))})
    except (OSError, subprocess.SubprocessError, ValueError, TypeError):
        pass
    print(json.dumps({'processes': processes, 'apps': apps}))


if __name__ == '__main__':
    main()
