FROM nvidia/cuda:12.8.0-runtime-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive
ARG CODEX_VERSION=0.101.0

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tmux procps nodejs npm ca-certificates curl git \
 && npm install -g "@openai/codex@${CODEX_VERSION}" \
 && npm cache clean --force \
 && rm -rf /var/lib/apt/lists/*

# Default home for the moor user (created at runtime via bind-mounted passwd)
RUN mkdir -p /home/moor && chmod 777 /home/moor

CMD ["sleep", "infinity"]
