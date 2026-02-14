# moor

a dock for your coding agents.

## the problem

you have a cluster with expensive GPUs. you want to run AI coding agents — codex, claude, etc — on long-running tasks. but giving an autonomous agent unrestricted access to a shared HPC machine is a bad idea.

codex's built-in sandbox ([openai/codex#3141](https://github.com/openai/codex/issues/3141)) blocks GPU access on linux. so you're stuck choosing between safety and actually using your hardware.

## the idea

docker is the sandbox. tmux is the persistence layer.

moor launches a GPU-enabled container, drops you into a tmux session, and lets the agent run with full permissions inside. the container can see your repo and your conda envs, but nothing else. you can detach, close your terminal, go home. come back the next day, reattach, and the agent is still working.

```
host
 └── moor
      └── docker container (the dock)
           ├── your repo at /work/repo
           ├── host conda envs (rw)
           ├── all GPUs via nvidia container toolkit
           ├── tmux session (persistent)
           └── coding agent (no restrictions)
```

## what's moored

the container **can**:
- read and write your repo
- use all GPUs (cuda, nvml, the works)
- install conda packages in your envs
- run any syscall (seccomp=unconfined, required for cuda ioctl)

the container **cannot**:
- see anything outside the mounted directories
- run as root or escalate privileges
- see or signal host processes
- escape the container namespace

## install

```bash
git clone https://github.com/gguiomar/moor.git
cd moor
./install.sh
```

this copies `moor` to `~/.local/bin/` and builds the docker image.

### requirements

- linux with nvidia GPUs
- docker with [nvidia container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html)
- conda/miniconda (optional, for environment management)

## usage

```bash
# from any repo directory — auto-detects conda env by dir name
moor

# specify a conda env
moor my-env

# check what's running
moor --status

# tear down and start fresh
moor --reset
```

inside the container, `codex` is wrapped to bypass its internal sandbox automatically. docker is already doing that job.

**detach**: `ctrl+b` then `d`
**reattach**: run `moor` again

## configuration

| variable | default | what it does |
|---|---|---|
| `MOOR_IMAGE` | `moor/cuda:12.8.0-runtime-ubuntu24.04-tmux` | docker image to use |
| `MOOR_IMAGE_BUILD_DIR` | _(none)_ | auto-build from this dockerfile directory |

## cargo manifest

```
moor/
├── bin/moor            # the main script
├── docker/Dockerfile   # container image (cuda + tmux + codex)
├── share/codex-wrapper # sandbox bypass wrapper
├── install.sh          # self-setup
└── README.md           # you are here
```

## license

MIT
