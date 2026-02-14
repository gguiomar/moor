# moor

GPU-sandboxed runner for AI coding agents. Run [Codex](https://github.com/openai/codex) (or similar tools) inside a Docker container with full CUDA/GPU access while keeping your host machine safe.

## Why

AI coding agents like Codex need broad filesystem and execution permissions to be useful (`--full-auto`). But running them unsandboxed on a machine with GPUs, data, and shared resources is risky. Codex's built-in Landlock/seccomp sandbox blocks GPU access on Linux ([openai/codex#3141](https://github.com/openai/codex/issues/3141)).

**moor** solves this by:
- Running the agent inside a Docker container (the real sandbox)
- Bypassing Codex's internal sandbox (which blocks CUDA)
- Mounting only what's needed: your repo, conda envs, and codex config
- Giving the agent full GPU access via NVIDIA Container Toolkit
- Using tmux for persistent sessions you can detach/reattach

## Requirements

- Linux with NVIDIA GPUs
- Docker with [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- (Optional) Conda/Miniconda for environment management

## Install

```bash
git clone https://github.com/gguiomar/moor.git
cd moor
./install.sh
```

The installer copies `moor` to `~/.local/bin/` and optionally builds the Docker image.

## Usage

```bash
# From any repo directory — auto-detects conda env by dir name
moor

# Specify a conda env explicitly
moor my-env

# Check container status
moor --status

# Destroy and recreate
moor --reset
moor
```

Inside the container, `codex` automatically runs with `--dangerously-bypass-approvals-and-sandbox` since Docker provides the isolation.

**Detach** from the tmux session with `Ctrl+b` then `d`. **Reattach** by running `moor` again.

## How it works

```
┌─── Host ──────────────────────────────────────┐
│                                               │
│  moor (bash script)                           │
│    │                                          │
│    ├── Generates runtime files (passwd, etc.) │
│    ├── Creates/starts Docker container        │
│    └── Attaches via tmux                      │
│                                               │
│  ┌─── Docker container ───────────────────┐   │
│  │  - NVIDIA GPUs (--gpus all)            │   │
│  │  - Your repo at /work/repo             │   │
│  │  - Host conda envs (rw)               │   │
│  │  - Codex config (~/.codex)            │   │
│  │  - seccomp=unconfined (for CUDA)      │   │
│  │  - Non-root user, no sudo             │   │
│  │  - PID limit 4096                      │   │
│  │  - codex wrapper (bypass sandbox)      │   │
│  └────────────────────────────────────────┘   │
└───────────────────────────────────────────────┘
```

## Container isolation

The container **cannot**:
- Access host files outside the mounted repo, conda, and codex config
- Run as root or use sudo
- See host processes
- Escape the container namespace

The container **can**:
- Read/write your repo directory
- Use all GPUs
- Install/remove conda packages in mounted envs
- Make any syscall (seccomp=unconfined, needed for CUDA ioctl)

## Configuration

| Variable | Default | Description |
|---|---|---|
| `MOOR_IMAGE` | `moor/cuda:12.8.0-runtime-ubuntu24.04-tmux` | Docker image |
| `MOOR_IMAGE_BUILD_DIR` | _(none)_ | Auto-build image from this Dockerfile dir |

## Project structure

```
moor/
├── bin/moor          # Main script
├── docker/Dockerfile # Container image
├── share/codex-wrapper  # Reference wrapper script
├── install.sh        # Installer
└── README.md
```

## License

MIT
