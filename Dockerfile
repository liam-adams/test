FROM python:3.9-slim-buster

RUN apt-get update -y

# https://serverfault.com/a/801162
ENV LANG=en_US.UTF-8
RUN apt-get install -y locales && \
    sed -i -e "s/# $LANG.*/$LANG UTF-8/" /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=$LANG

COPY . /app
RUN pip install -r /app/requirements.txt
WORKDIR /app/searchapi

CMD python server.py