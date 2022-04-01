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
	    -p 54321:54321                   \
	    -v $(SOURCE):$(CODE):Z           \
	    -v $(SOURCE_COMMON):$(COMMON):Z  \
	    -e TEST_REMOTE_USER=praiskup     \
	    --tmpfs=/tmp                     \
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
