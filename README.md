# Webdavis Neovim Config

This is my Neovim config, powered by [lazy.nvim](https://github.com/folke/lazy.nvim).

## Navigating this Repo

The following modules/files run the show:

| Module／File                                  | Description                                                                                  |
| -------------------------------------------- | -------------------------------------------------------------------------------------------- |
| **[init](./init.lua)**                       | Main entry point.                                                                            |
| **[lazy.nvim setup](./lua/config/lazy.lua)** | Initializes `lazy.nvim` plugin manager and loads all plugins from `lua/plugins/`             |
| **[options](./lua/config/options.lua)**      | Global／default Neovim options.                                                               |
| **[autocmds](./lua/config/autocmds.lua)**    | Auto commands for filetypes, events, etc.                                                    |
| **[keymaps](./lua/config/keymaps.lua)**      | Global keyboard shortcuts (note: some plugin-specific mappings are put here for convenience) |
| **[plugins/](./lua/plugins)**                | Individual plugin configurations.                                                            |

> [!NOTE]
>
> Most `plugin-specific-keymaps` are defined within their respective plugin files.

## Profiling Neovim Startup Time

To profile startup time, set the `PROFILE` environment variable before launching Neovim:

```bash
PROFILE=1 nvim
```
