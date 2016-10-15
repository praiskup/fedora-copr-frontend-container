WORKDIR  = /copr
CODE     = $(WORKDIR)/coprs_frontend
SOURCE   = `pwd`/../coprs_frontend
NAME     = copr-frontend
UID      = $(shell id -u)
USERNAME = $(shell id -u -n)
PORT     = 55555
SQLFILE  = /sql-file
ifdef SQLSOURCE
    SQLMOUNT = -v $(SQLSOURCE):$(SQLFILE):ro,Z
endif

.PHONY: build run

run: build
	$(MAKE) run-only

run-only:
	docker run --rm -ti                  \
	    -p $(PORT):$(PORT)               \
	    -v $(SOURCE):$(CODE):Z,ro        \
	    $(SQLMOUNT)                      \
	    $(NAME) $(CMD)

build:
	docker build                         \
	    --build-arg=UID=$(UID)           \
	    --build-arg=CODE=$(CODE)         \
	    --build-arg=WORKDIR=$(WORKDIR)   \
	    --build-arg=USERNAME=$(USERNAME) \
	    --build-arg=PORT=$(PORT)         \
	    --tag $(NAME)                    \
	    .
