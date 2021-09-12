FROM alpine:latest

ARG USER_UID=1000
ARG USER_NAME=dev

RUN apk update && \
  apk add ansible git bash openssh nodejs npm sudo yarn sshpass python3 py3-pip && \
  rm -rf /var/cache/apk/*

RUN yarn global add commitizen cz-emoji
RUN pip3 install ansible-lint
RUN adduser -D -u ${USER_UID} -s /bin/bash ${USER_NAME} && \
  echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo '{ "path": "cz-emoji" }' > /home/${USER_NAME}/.czrc && chown ${USER_NAME} /home/${USER_NAME}/.czrc
