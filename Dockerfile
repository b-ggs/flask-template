####################
# Base build stage #
####################

# Make sure Python version is in sync with CI configs
FROM python:3.13-bookworm AS base

# Set up unprivileged user
RUN useradd --create-home flask_template

# Set up project directory
ENV APP_DIR=/app
RUN mkdir -p "$APP_DIR" \
  && chown -R flask_template:flask_template "$APP_DIR"

# Set up virtualenv
ENV VIRTUAL_ENV=/venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH
RUN mkdir -p "$VIRTUAL_ENV" \
  && chown -R flask_template:flask_template "$VIRTUAL_ENV"

# Install Poetry
# Make sure Poetry version is in sync with CI configs
ENV POETRY_VERSION=1.8.5
ENV POETRY_HOME=/opt/poetry
ENV PATH=$POETRY_HOME/bin:$PATH
RUN curl -sSL https://install.python-poetry.org | python3 - \
  && chown -R flask_template:flask_template "$POETRY_HOME"

# Switch to unprivileged user
USER flask_template

# Switch to project directory
WORKDIR $APP_DIR

# Set environment variables
# - PYTHONUNBUFFERED: Force Python stdout and stderr streams to be unbuffered
# - PORT: Set port that is used by Gunicorn. This should match the "EXPOSE"
#   command
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Install main project dependencies
COPY --chown=flask_template:flask_template pyproject.toml poetry.lock ./
RUN --mount=type=cache,target=/home/flask_template/.cache/pypoetry,uid=1000 \
  python3 -m venv $VIRTUAL_ENV \
  && poetry install --only main

# Port used by this container to serve HTTP
EXPOSE 8000

# Serve project with gunicorn
CMD ["gunicorn", "flask_template:create_app()"]

##########################
# Production build stage #
##########################

FROM base AS production

# Copy the project files
# Ensure that this is one of the last commands for better layer caching
COPY --chown=flask_template:flask_template . .

###################
# Dev build stage #
###################

FROM base AS dev

# Install all project dependencies

RUN --mount=type=cache,target=/home/flask_template/.cache/pypoetry,uid=1000 \
  poetry install

# Install poetry-plugin-up for bumping Poetry dependencies
RUN --mount=type=cache,target=/home/flask_template/.cache/pypoetry,uid=1000 \
  poetry self add poetry-plugin-up

# Add bash aliases
RUN echo "alias flaskrun='flask --app flask_template run --host 0.0.0.0 --port 8000 --debug'" >> $HOME/.bash_aliases

# Copy the project files
# Ensure that this is one of the last commands for better layer caching
COPY --chown=flask_template:flask_template . .
