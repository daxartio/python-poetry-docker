FROM python:3-slim-buster as built

WORKDIR /opt/app

COPY ./pip.conf /etc/pip.conf

ARG POETRY_VERSION=1.3.1
RUN pip install "poetry==$POETRY_VERSION" \
    && poetry config virtualenvs.create true \
    && poetry config virtualenvs.in-project true \
    && poetry config virtualenvs.options.no-pip true \
    && poetry config virtualenvs.options.no-setuptools true \
    && poetry config virtualenvs.options.system-site-packages true

COPY pyproject.toml poetry.lock /opt/app/
RUN poetry install --only main --no-interaction --no-ansi

FROM python:3-slim-buster

WORKDIR /opt/app

ENV PYTHONDONTWRITEBYTECODE=off
ENV PYTHONFAULTHANDLER=on
ENV PYTHONUNBUFFERED=on
ENV PYTHONPATH=/opt/app

COPY --from=built /opt/app/.venv /opt/app/.venv
COPY main.py /opt/app/

ENV PATH="/opt/app/.venv/bin:$PATH"

RUN python -m compileall

CMD [ "python", "main.py" ]
