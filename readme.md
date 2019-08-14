# Superdesk dev utils

## Install

Requires `sudo`

```bash
$ ./install.sh
```

## Usage

```bash
  - Show this help

  sd help

  - Start the client

  sd client

  - Start the server

  sd server

  - Start the client with a custom server (e.g sd-master)

  sd grunt <server-id>

  - Start the client with localhost as a server but with SSL

  sd vps

  - Start the client with sd-master as server

  sd remote

  - Start the local server for tests

  sd test

  - Run e2e tests

  sd e2e

  - Run unit tests

  sd unit

  - Kill remaining server processes

  sd kill

  Install dependencies for a project (e.g -planning)

  sd deps <-project>

  - Drop superdesk database

  sd drop_database

  - Initialize data and prepopulate for a specific project (e.g -belga)

  sd prepopulate <-project>

  - Show your commits from all projects (use 'last' argument for last month period)

  sd timetrack <last>
```

