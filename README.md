# Production Setup for GoClaw

For production ready deployment of goclaw, here the runtime environment is
decoupled from the upstream goclaw codebase.

Using mise-en-place to manage the environment/tools and secrets we aim
to support multiple production targets.

We will be focusing on rootless-podman but will anticiplate alternatives,
selectable via `./.miserc.toml`

- mise/config.podman.toml
- mise/mise.k8s.toml
- mise/config.docker.toml

## Features

- Target **rootless-podman**, (podman, docker, k8s, an-other )
- Mise-en-place to manage environment/tools and secrets
- Decouple data storage to use alternative backend file systems (i.e. ZFS)
- Self-improving containers capability (buildah)

## Runtime Environment Assumptions

- Mise-en-place is the host environment manager
- Buildah is available.

## Podman Configuration

### Quick Start

```bash
./podman/setup-rootless.sh
```

### podman/files

| File | Purpose |
|------|---------|
| `podman/setup-rootless.sh` | Copies `config/containers/` to `~/.config/containers/` |
| `podman/config/containers/` | Podman config directory |
| `podman/config/containers/containers.conf` | userns=keep-id, group_add |
| `podman/config/containers/storage.conf` | Overlay storage driver at `/opt/storage` |
| `podman/config/containers/registries.conf` | Add docker.io as default search |
| `podman/podman+network-fix.yml` | Compose overlay for network settings |
| `podman/podman+user-fix.yml` | User namespace fixes |

## Podman Storage

These are configured in the files above, and may be changed as needed. Batteries included defaults:

- File System - Podman rootless uses overlayfs. Mount a suitable volume at /opt/storage
- Data - For data we are using /srv as the mount point parent.

#### Database permissions

Normally Postgres expects the container to be started as root UID 0, and later it
switches the postgres process to run as UID postgres(999). 

Alternatively if it finds that it has been started as another UID, it will use
that UID, and attempt to update the permissions of all files to match that UID.

With `keep-id` set, the container runs rootless as the host user id.
the attempt to change permissions may fail due to lack of
permissions, but as long as the persisted files are owned by the
user it will work.

```
# permissions fix
chown -R $(id -u):$(id -g) /srv/$COMPOSE_PROJECT_NAME_postgres-data
```

## See Also

- [Podman Networking](https://docs.podman.io/en/latest/markdown/podman.1.html#network)
- [aardvark-dns](https://github.com/containers/aardvark-dns)
- [Nginx Resolver](https://nginx.org/en/docs/http/ngx_http_core_module.html#resolver)
- [Self-Building Container](./SELF_BUILDING.md)
