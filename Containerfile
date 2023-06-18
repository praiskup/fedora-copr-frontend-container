FROM registry.fedoraproject.org/fedora:38

MAINTAINER Pavel Raiskup <praiskup@redhat.com>

ENV COPR_CONFIG=/copr/copr.config \
    PGDATABASE=coprdb \
    PYTHONDONTWRITEBYTECODE=yes \
    LANG=C.UTF-8

RUN dnf -y --setopt=tsflags=nodocs install dnf dnf-plugins-core \
    && dnf -y copr enable @copr/copr-dev \
    && dnf -y copr enable praiskup/flask-shell-ipython \
    && dnf -y --setopt=tsflags=nodocs install \
        copr-frontend \
        dnf \
        findutils \
        html2text \
        htop \
        ipython3 \
        js-jquery \
        libmodulemd \
        mod_wsgi \
        passwd \
        postgresql-server \
        procps-ng \
        psmisc \
        pspg \
        python3-anytree \
        python3-backoff \
        python3-sqlalchemy-utils \
        python3-email-validator \
        python3-ipdb \
        python3-pip \
        python3-psutil \
        python3-flask-restx \
        python3-flask-caching \
        python3-flask-shell-ipython \
        python3-templated-dictionary \
        tmux \
        vim \
        xz \
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
    PYTHONPATH=/copr/coprs_frontend:/copr/common:/usr/local/lib/python3.9/site-packages

WORKDIR $WORKDIR

ADD container-build container-run /
RUN /container-build
RUN chown $USERNAME /container-run /var/lib/copr/data/srpm_storage/

USER $USERNAME

RUN initdb $PGDATA

RUN echo "log_min_duration_statement = 40" >> "$PGDATA"/postgresql.conf

RUN echo "shared_buffers = 400" >> "$PGDATA"/postgresql.conf

CMD ["/container-run"]
