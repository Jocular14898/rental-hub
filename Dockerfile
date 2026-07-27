FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev gcc \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8200

ENV FLASK_ENV=production

CMD ["gunicorn", "--bind", "0.0.0.0:8200", "--workers", "2", "--timeout", "60", "--preload", "wsgi:application"]
