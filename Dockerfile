FROM python:3.13-slim
WORKDIR /app

# Install the system and application dependencies
COPY requirements.txt ./
RUN apt-get update \
 && apt-get install -y --no-install-recommends gcc libc-dev \
 && pip install --no-cache-dir -r requirements.txt \
 && apt-get remove -y gcc libc-dev \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

# Copy in the source code
COPY . .
EXPOSE 6000

# Train the model
RUN python3 model/train.py

# Setup an app user so the container doesn't run as the root user
#RUN useradd app
#USER app

# Start the app with gunicorn (4 workers, bind to 0.0.0.0:6000)
CMD ["gunicorn", "--workers", "4", "--bind", "0.0.0.0:6000","app:app"]