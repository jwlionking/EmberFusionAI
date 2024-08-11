FROM phusion/baseimage:bionic-1.0.0
LABEL maintainer="EFUS Developers <dev@efus.org>"
LABEL description="Dockerised EFUSCore, built from Travis"

ARG USER_ID
ARG GROUP_ID

ENV HOME /home/efus

# add user with specified (or default) user/group ids
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}
RUN groupadd -g ${GROUP_ID} efus && \
    useradd -u ${USER_ID} -g efus -s /bin/bash -m -d /home/efus efus && \
    mkdir /home/efus/.efuscore && \
    chown ${USER_ID}:${GROUP_ID} -R /home/efus

COPY bin/* /usr/local/bin/

RUN chmod a+x /usr/local/bin/*

USER efus

VOLUME ["/home/efus"]

EXPOSE 12971 12972 19998 19999

WORKDIR /home/efus
