FROM alpine:3.11

ARG USER_UID=1000
ARG USER_NAME=dev

ARG ANSIBLE_VER=2.9.14-r0
ARG COMMITIZEN_VER=4.0.3
ARG CZ_EMOJI_VER=1.1.2
RUN apk update && \
  apk add ansible=${ANSIBLE_VER} git bash openssh nodejs npm sudo yarn sshpass && \
  rm -rf /var/cache/apk/*

RUN yarn global add commitizen@${COMMITIZEN_VER} cz-emoji@${CZ_EMOJI_VER}
RUN adduser -D -u ${USER_UID} -s /bin/bash ${USER_NAME} && \
  echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN echo '{ "path": "cz-emoji" }' > /home/${USER_NAME}/.czrc && chown ${USER_NAME} /home/${USER_NAME}/.czrc
