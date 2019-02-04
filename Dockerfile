FROM registry.fedoraproject.org/fedora:29
MAINTAINER Pavel Raiskup <praiskup@redhat.com>

ENV container="docker" \
    COPR_CONFIG=/copr/copr.config

RUN dnf -y --setopt=tsflags=nodocs install dnf dnf-plugins-core \
    && dnf -y copr enable praiskup/copr-dev \
    && dnf -y --setopt=tsflags=nodocs install \
        copr-frontend \
        postgresql-server \
        ipython3 \
        mod_wsgi \
        passwd \
        dnf \
        findutils \
        tmux \
        libmodulemd \
        procps-ng \
    && mkdir -p /var/log/copr-frontend \
    && dnf -y --setopt=tsflags=nodocs clean all --enablerepo='*'

ARG USERNAME
ARG UID
ARG WORKDIR=/copr
ARG CODE
ARG PGDATA
ARG PORT=55555
ARG FE_HOST=localhost:$PORT

ENV PGPORT=54321 \
    PGHOST=/tmp \
    PYTHONPATH=/copr/coprs_frontend:/copr/common

WORKDIR $WORKDIR

ADD container-build container-run /
RUN /container-build
RUN chown $USERNAME /container-run /var/lib/copr/data/srpm_storage/

USER $UID

RUN initdb $PGDATA

CMD ["/container-run"]
