# Small official Python 3.12 image
FROM python:3.12-slim

# Work inside /app in the container
WORKDIR /app

# Copy requirements first so Docker can cache the install step
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app code
COPY app.py .

# Bonus: create and use a non-root user
RUN useradd --create-home appuser
USER appuser

# The app listens on port 5000 inside the container
EXPOSE 5000

CMD ["python", "app.py"]
