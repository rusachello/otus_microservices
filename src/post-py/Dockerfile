FROM python:3.6.0-alpine

WORKDIR /app
ADD . /app

RUN apk --no-cache --update add musl-dev gcc build-base && \
    pip install -r /app/requirements.txt && \
    apk del build-base musl-dev gcc

ENV POST_DATABASE_HOST post_db
ENV POST_DATABASE posts

ENTRYPOINT ["python3", "post_app.py"]
