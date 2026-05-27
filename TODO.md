# TODO

## Multi-deployment coexistence
- [x] Network key in podclaws compose files renamed from `goclaw-net` to `net` (auto-generates as `{project_name}_net`)
- [ ] Note: `goclaw/` submodule defines its own `goclaw-net` key in compose files — cannot change from here, auto-generates as `{project_name}_goclaw-net` for goclaw services
- [ ] Verify `sensible-tasks` volume naming doesn't conflict between deployments