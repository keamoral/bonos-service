# ── Etapa 1: builder ──────────────────────────────────────────
FROM python:3.12-slim AS builder

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ── Etapa 2: runtime ───────────────────────────────────────────
FROM python:3.12-slim AS runtime

WORKDIR /app

# Usuario no root
RUN useradd --create-home --shell /bin/bash appuser

# Copiar las dependencias ya instaladas desde el builder
COPY --from=builder /root/.local /home/appuser/.local
ENV PATH=/home/appuser/.local/bin:$PATH

# Copiar el código de la aplicación
COPY app/ ./app/

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8004

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8004"]