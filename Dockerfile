FROM ubuntu:24.04

ENV UV_LINK_MODE=copy \
    PYTHONPATH=/app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends build-essential git && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user and group
RUN groupadd -g 10001 dumbgroup && \
    useradd -r -u 10001 -g dumbgroup -m -s /sbin/nologin dumbuser

WORKDIR /app
RUN mkdir /dumbkvstore && \
    chown -R dumbuser:dumbgroup /app /dumbkvstore

USER dumbuser

# Copy pyproject.toml and uv.lock first to leverage Docker layer caching
COPY --chown=dumbuser:dumbgroup pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project --python 3.12

# Copy application code
COPY --chown=dumbuser:dumbgroup . .

# Install app itself
RUN uv sync --frozen --no-dev --python 3.12

# Ensure virtualenv is used by default
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000

CMD ["uvicorn", "main:api", "--host", "0.0.0.0", "--port", "8000", "--log-config", "logging.yaml"]