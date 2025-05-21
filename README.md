# 🚀 Docker Compose Deploy via SSH

Deploy your Docker Compose-based application to a remote server over SSH – fast, simple and secure.

This GitHub Action uses `scp` and `ssh` to upload files and run `docker compose` on your server. It optionally verifies host identity using a `known_hosts` file. \
Build with the Alpine Docker image.

---

## ✨ Features

- 🔒 Connects via SSH with private key auth
- 📁 Uploads your `docker-compose.yml` and extra files/folders
- 🐳 Runs `docker compose` remotely with support for:
  - `pull`
  - `build`
  - `up -d`
  - `Additional Options` https://docs.docker.com/reference/cli/docker/compose/up/#options
- ⚙️ Optional pre- and post-commands
- ✅ Host identity verification via `known_hosts`
- 🧼 Automatic cleanup and error handling
- 🏔️ Lightweight Alpine-based Docker image for minimal footprint

---

## 📦 Inputs

| Name              | Description                                                                    | Required | Default              |
| ----------------- | ------------------------------------------------------------------------------ | -------- | -------------------- |
| `ssh_host`        | SSH Host                                                                       | ✅ Yes   | —                    |
| `ssh_user`        | SSH Username                                                                   | ✅ Yes   | —                    |
| `ssh_private_key` | SSH Private Key                                                                | ✅ Yes   | —                    |
| `ssh_port`        | SSH Port                                                                       | ❌ No    | `22`                 |
| `ssh_known_hosts` | Optional known_hosts content for host verification                             | ❌ No    | —                    |
| `project_path`    | Remote path to upload and deploy to                                            | ✅ Yes   | —                    |
| `pre_command`     | Optional command to run on the remote before `docker compose`                  | ❌ No    | —                    |
| `post_command`    | Optional command to run on the remote after `docker compose`                   | ❌ No    | —                    |
| `deploy_file`     | Path to your `docker-compose.yml` file (relative to project root)              | ❌ No    | `docker-compose.yml` |
| `extra_files`     | Comma-separated list of extra files/folders to upload                          | ❌ No    | —                    |
| `compose_pull`    | Run `docker compose pull` before starting (`true`/`false`)                     | ❌ No    | `true`               |
| `compose_build`   | Run `docker compose build` before starting (`true`/`false`)                    | ❌ No    | `false`              |
| `compose_args`    | Extra arguments passed directly to 'docker compose up' (e.g. --force-recreate) | ❌ No    | --remove-orphans     |

---

## 🛠 Example Usage

```yaml
name: 🚀 Deploy to Remote Server

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: 🧾 Checkout code
        uses: actions/checkout@v4

      - name: 🚀 Deploy via Docker Compose over SSH
        uses: dombyte/docker-deploy@v1
        with:
          ssh_host: ${{ secrets.SSH_HOST }}
          ssh_user: ${{ secrets.SSH_USER }}
          ssh_private_key: ${{ secrets.SSH_KEY }}
          ssh_known_hosts: ${{ secrets.KNOWN_HOSTS }}
          project_path: /home/user/app
          deploy_file: docker-compose.prod.yml
          extra_files: .env,nginx.conf,config/ # Comma-separated list of extra files/folders
          compose_pull: true
          compose_build: false
          #   compose_args: "--force-recreate" # Default arg --remove-orphans
          pre_command: "docker system prune -f" # command to run on the remote before `docker compose`
          post_command: "docker ps" # command to run on the remote after `docker compose`
```
