FROM python:3.11-slim

WORKDIR /app

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8200

ENV FLASK_ENV=production

CMD ["gunicorn", "--bind", "0.0.0.0:8200", "--workers", "4", "run:app"]
