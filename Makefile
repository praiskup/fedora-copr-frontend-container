WORKDIR  = /copr
CODE     = $(WORKDIR)/coprs_frontend
COMMON   = $(WORKDIR)/common
SOURCE   = `pwd`/../copr/frontend/coprs_frontend
SOURCE_COMMON = `pwd`/../copr/common
SOURCE_DIRS = $(SOURCE) $(SOURCE_COMMON)
NAME     = copr-frontend
UID      = $(shell id -u)
USERNAME = $(shell id -u -n)
PORT     = 55555
PGDATA   = /pgdata

ifdef INITDIR
    SQLMOUNT_ARGS = -v $(INITDIR):/copr.init.d:ro,Z
endif

.PHONY: build run fix-permissions

run: build
	$(MAKE) run-only

fix-permissions:
	umask 0002 ;                         \
	find $(SOURCE_DIRS) -type d             -exec chmod a+rx {} + ; \
	find $(SOURCE_DIRS) -type f             -exec chmod a+r  {} + ; \
	find $(SOURCE_DIRS) -type f -executable -exec chmod a+x  {} + ;

run-only: fix-permissions
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

delete:
	podman rmi copr-frontend

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
