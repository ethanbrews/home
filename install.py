#! python3

import argparse
import shutil
import json
import platform as _platform
from typing import Self
from enum import Enum
from pathlib import Path
from os import system as call

class OperatingSystem(Enum):
    WINDOWS = 'Windows'
    MAC = 'Darwin'
    LINUX = 'Linux'

    @property
    def this_os() -> Self:
        return OperatingSystem(_platform.system())


def ask_bool(prompt: str, default: bool = True) -> bool:
    if default:
        prompt += " (Y/n): "
    else:
        prompt += " (y/N): "

    answer = input(prompt).lower()

    if answer in ['y', 'yes']:
        return True
    elif answer in ['n', 'no']:
        return False
    elif answer == '':
        return default
    else:
        print('Invalid answer')
        return ask_bool(prompt, default)

def get_config_file():
    if OperatingSystem.this_os == OperatingSystem.WINDOWS:
        return Path.home() / "AppData" / "Local" / 'dotfiles' / 'config.json'
    else:
        return Path.home() / ".config" / 'dotfiles' / 'config.json'


def parse_config():
    if not get_config_file().exists():
        print('No config found. Run `configure` command.')

    with open(get_config_file(), 'r') as f:
        return json.loads(f.read())


def show_config():
    config = parse_config()
    for section in config.sections():
        print(f"[{section}]")
        for key in config[section]:
            print(f"{key} = {config[section][key]}")
        print()


def do_configure():
    config_file = get_config_file()
    if config_file.exists():
        if not ask_bool('Config already exists. Overwrite?', False):
            return
        
    config_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open('config-template.json', 'r') as f:
        defaults = json.loads(f.read())

    for k in set(defaults) - {'packages'}:
        print(f'{k}: {defaults[k]}')
        if not ask_bool(f'Use defaults for {k}?', True):
            del defaults[k]
    
    if 'packages' not in defaults:
        defaults['packages'] = []
    defaults['packages'] = {k: defaults['packages'][k] for k in defaults['packages'] if ask_bool(f'Use defaults for {k} ({defaults['packages'][k]})?', True)}

    with config_file.open('w') as f:
        f.write(json.dumps(defaults, indent=4))


def do_sync():
    config = parse_config()
    for c in config.get('config', list()):
        src, dst = Path(c['from']).expanduser().resolve(), Path(c['to']).expanduser().resolve()

        if not src.exists():
            print(f'Cannot find config at {src}')
            continue

        if not dst.exists():
            print(f'Create directory {dst}')
            dst.mkdir(parents=True, exist_ok=True)

        dst_items = list(map(lambda x: x.name, dst.iterdir()))
        for item in src.iterdir():
            if item.name in dst_items:
                if not (dst / item.name).is_symlink():
                    print(f'Cannot overwrite {dst / item.name}')
            else:
                print(f'Make link from {item} to {dst / item.name}')
                (dst / item.name).symlink_to(item)


    for script in config.get('scripts', list()):
        print(f'Call {script}')
        call(script)
    

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('action', choices=['sync', 'show-config', 'where-config', 'configure'])
    args = parser.parse_args()

    if args.action == 'sync':
        do_sync()
    if args.action == 'configure':
        do_configure()
    elif args.action == 'show-config':
        show_config()
    elif args.action == 'where-config':
        print(get_config_file())
    else:
        raise ValueError(f"Unknown action: {args.action}")
    
if __name__ == '__main__':
    main()