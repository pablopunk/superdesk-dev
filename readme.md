# Superdesk dev utils

## Install

Requires `sudo`

```bash
$ ./install.sh
```

## Usage

I don't directly use this in the CLI, I usually use this `tmuxinator` session [here](https://github.com/pablopunk/dotfiles/blob/master/tmuxinator/sd.yml)

```bash
- Show this help

sd help

- Start the client with a custom server (e.g sd-master)

sd grunt <server-id>

- Kill remaining server processes

sd kill

Install dependencies for a project (e.g -planning)

sd deps <-project>

- Drop superdesk database

sd wipe

- Initialize data and populate for a specific project (e.g -belga)

sd populate <-project>

- Show your commits from all projects (use 'last' argument for last month period)

sd timetrack <last>
```

