FROM python:3.11-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3-pip \
    chromium \
    chromium-driver \
    xvfb \
    xauth \
    libfontconfig1 \
    libnss3 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

COPY . /app

FROM base AS test_runner

ENV DISPLAY=:99

RUN xvfb-run pytest tests_ui/test_sprint2_ui.py

FROM base AS prod