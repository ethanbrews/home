#!/usr/bin/env python3
import iterm2

async def main(connection):
    app = await iterm2.async_get_app(connection)
    window = app.current_terminal_window
    if not window:
        print("none")
        return
    session = window.current_tab.current_session
    profile = await session.async_get_profile()
    if profile.use_tab_color:
        c = profile.tab_color
        print(f"{int(c.red)} {int(c.green)} {int(c.blue)}")
    else:
        print("none")

iterm2.run_until_complete(main)
