FROM index.docker.io/fedora:rawhide
MAINTAINER unknown <unknown@unknown.com>

ENV container="docker" \
    COPR_CONFIG=/copr/copr.config

RUN dnf -y --setopt=tsflags=nodocs install dnf dnf-plugins-core \
    && dnf -y copr enable @modularity/modulemd \
    && dnf -y --setopt=tsflags=nodocs install postgresql-server \
        python3 \
        python3-alembic \
        python3-flask \
        python3-flask-openid \
        python3-openid-teams \
        python3-flask-wtf \
        python3-flask-sqlalchemy \
        python3-flask-script \
        python3-flask-whooshee \
        python3-blinker \
        python3-markdown \
        python3-psycopg2 \
        python3-pylibravatar \
        python3-CommonMark \
        python3-requests \
        python3-whoosh \
        python3-pytz \
        python3-six \
        python3-netaddr \
        python3-flask-restful \
        python3-marshmallow \
        python3-modulemd \
        python3-pygments \
        python3-pytest \
        python3-flexmock \
        python3-mock \
        python3-decorator \
        python3-redis \
        python3-dnf \
        python3-wtforms \
        ipython3 \
        httpd mod_wsgi passwd \
        yum redis \
        python3-dateutil crontabs \
        dnf findutils \
        copr-frontend tmux \
        procps-ng \
    && mkdir -p /var/log/copr-frontend \
    && dnf -y --setopt=tsflags=nodocs clean all --enablerepo='*'

ARG USERNAME
ARG UID
ARG WORKDIR=/copr
ARG CODE
ARG PGDATA=/pgdata
ARG PORT=55555
ARG FE_HOST=localhost:$PORT

ENV PGPORT=54321 \
    PGHOST=/tmp \
    PYTHONPATH=/copr/coprs_frontend

WORKDIR $WORKDIR

ADD container-build container-run /
RUN /container-build
RUN chown $USERNAME /container-run /var/lib/copr/data/srpm_storage/

USER $USERNAME
CMD ["/container-run"]
