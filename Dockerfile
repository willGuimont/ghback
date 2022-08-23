FROM elixir:latest

ARG SSH_ID_PATH=./ssh_keys/id_ed25519

COPY ${SSH_ID_PATH} /root/.ssh/
RUN echo "Host *\n\tStrictHostKeyChecking no\n\tUserKnownHostsFile=/dev/null\n" >> /root/.ssh/config

RUN apt update
RUN apt install -y git
RUN git config --global pull.ff only

COPY . /usr/app
WORKDIR /usr/app

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get
RUN mix compile

ARG GHBACKUP_PATH=/usr/app/backup
ENV GHBACKUP_PATH=${GHBACKUP_PATH}

CMD ["mix", "run"]
