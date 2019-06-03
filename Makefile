WORKDIR  = /copr
CODE     = $(WORKDIR)/coprs_frontend
COMMON   = $(WORKDIR)/common
SOURCE   = `pwd`/../copr/frontend/coprs_frontend
SOURCE_COMMON = `pwd`/../copr/common
NAME     = copr-frontend
UID      = $(shell id -u)
USERNAME = $(shell id -u -n)
PORT     = 55555
PGDATA   = /pgdata

ifdef INITDIR
    SQLMOUNT_ARGS = -v $(INITDIR):/copr.init.d:ro,Z
endif

.PHONY: build run

run: build
	$(MAKE) run-only

run-only:
	umask 0002 ;                         \
	podman run --rm -ti                  \
	    -p $(PORT):$(PORT)               \
	    -v $(SOURCE):$(CODE):Z,rw        \
	    -v $(SOURCE_COMMON):$(COMMON):Z,rw \
	    -e TEST_REMOTE_USER=praiskup     \
	    $(SQLMOUNT_ARGS)                 \
	    $(NAME) $(CMD)

build:
	umask 0002 ;                         \
	buildah bud                          \
	    --layers                         \
	    --tag $(NAME)                    \
	    --build-arg=UID=$(UID)           \
	    --build-arg=CODE=$(CODE)         \
	    --build-arg=WORKDIR=$(WORKDIR)   \
	    --build-arg=USERNAME=$(USERNAME) \
	    --build-arg=PORT=$(PORT)         \
	    --build-arg=PGDATA=$(PGDATA)     \
	    .
