# wynn-bridge

Wynn Bridge is a project that aims to improve the guild experience in wynncraft by providinga variety of utilities that help integrate discord into the game. It consists of a [bot](https://github.com/ezlixp/ogybot-discord.git), a [web api](https://github.com/ezlixp/ico-server.git), and a [minecraft mod](https://github.com/ezlixp/guild-api.git).

# Pull Requests

All pull requests are welcome and heavily appreciated, however please make sure to make them in the correct repository (likely one of the 3 linked above).

# Workspace Setup

## Initial Setup

To set up the workspace, simply clone this repository. Then run `git submodule update`, and populate .env with the format of appsettings.json in ogybot-discord/ogybot.Bot and .env.dockerdev in ico-server.

## Testing

To test your changes, use the provided unit tests, or run the project using `docker compose up --build`.

