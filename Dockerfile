FROM index.docker.io/fedora:25
MAINTAINER unknown <unknown@unknown.com>

ENV container="docker" \
    COPR_CONFIG=/copr/copr.config

RUN dnf -y --setopt=tsflags=nodocs install dnf dnf-plugins-core \
    && dnf -y copr enable @modularity/modulemd \
    && dnf -y --setopt=tsflags=nodocs install postgresql-server python httpd mod_wsgi passwd python-alembic python-flask python-flask-openid python-openid-teams python-flask-wtf python-flask-sqlalchemy python-flask-script python-flask-whooshee python-blinker python-markdown python-psycopg2 python-pylibravatar python2-requests python-whoosh pytz python-six python-netaddr python-flask-restful python-marshmallow python2-modulemd python-pygments pytest python-flexmock python-mock python-decorator yum redis python-redis python-dateutil crontabs python-dnf dnf findutils \
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
    PGHOST=/tmp

WORKDIR $WORKDIR

ADD container-build container-run /
RUN /container-build
RUN chown $USERNAME /container-run

USER $USERNAME
CMD ["/container-run"]
