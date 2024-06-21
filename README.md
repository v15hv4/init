# init

## Installation
```
curl -fsSL https://raw.githubusercontent.com/v15hv4/init/$PROFILE/setup.sh | sh
```

## Profiles
- [cos-personal](https://github.com/v15hv4/init/tree/cos-personal)
- [cos-work](https://github.com/v15hv4/init/tree/cos-work)
- [debian-server](https://github.com/v15hv4/init/tree/debian-server)

## Organization
| Content                  | Repo Location                        | Host Location              |
|--------------------------|--------------------------------------|----------------------------|
| Global configs           | branch: `dotfiles`, path: `.`        | `~/.dotfiles`              |
| Profile-specific configs | branch: `$PROFILE`, path: `dotfiles` | `~/.init-profile/dotfiles` |

In case a config exists in both the directories, the profile-specifc config will overwrite the global one.
