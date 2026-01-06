FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
 ca-certificates curl \
 && update-ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd --system --gid 999 nonroot \
 && useradd --system --gid 999 --uid 999 --create-home nonroot

RUN npm install -g @openai/codex

WORKDIR /workspace

RUN chown -R nonroot:nonroot /workspace

USER nonroot
ENV HOME=/home/nonroot

ENTRYPOINT ["codex"]
