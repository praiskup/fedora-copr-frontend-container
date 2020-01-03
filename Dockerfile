FROM registry.fedoraproject.org/fedora:31
MAINTAINER Pavel Raiskup <praiskup@redhat.com>

ENV COPR_CONFIG=/copr/copr.config \
    PGDATABASE=coprdb \
    PYTHONDONTWRITEBYTECODE=yes

RUN dnf -y --setopt=tsflags=nodocs install dnf dnf-plugins-core \
    && dnf -y copr enable @copr/copr-dev \
    && dnf -y --setopt=tsflags=nodocs install \
        copr-frontend \
        dnf \
        findutils \
        html2text \
        ipython3 \
        libmodulemd \
        mod_wsgi \
        passwd \
        postgresql-server \
        procps-ng \
        pspg \
        python3-ipdb \
        python3-pip \
        python3-flask-cache \
        tmux \
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

USER $USERNAME

RUN initdb $PGDATA

RUN echo "log_min_duration_statement = 100" >> "$PGDATA"/postgresql.conf

CMD ["/container-run"]
