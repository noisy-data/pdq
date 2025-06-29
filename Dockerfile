# -- Base Image --
# Install uv, setup runtime user
FROM python:3.13 as base
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Setup application runtime user
RUN adduser --uid=1000 worker
USER worker
WORKDIR /home/worker

# Enable bytecode compilation
# Copy from the cache instead of linking since it's a mounted volume
ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Install the project's dependencies using the lockfile and settings
RUN --mount=type=cache,target=/home/worker/.cache/uv,uid=1000 \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project --no-dev

# Then, add the rest of the project source code and install it
# Installing separately from its dependencies allows optimal layer caching
COPY --chown=worker:worker . ./app
WORKDIR /home/worker/app
RUN --mount=type=cache,target=/home/worker/.cache/uv,uid=1000 \
    uv sync --locked --no-dev

# Place executables in the environment at the front of the path
ENV PATH="/home/worker/app/.venv/bin:$PATH"

# Reset the entrypoint, don't invoke `uv`
ENTRYPOINT []
CMD [ "uv", "run", "src/pdq"]
