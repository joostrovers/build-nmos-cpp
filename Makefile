NAME = nmos-virtual-node

NMOS_CPP_VERSION = $(shell head -n 1 version.txt)
VERSION = 0.1-$(NMOS_CPP_VERSION)

# Get number of processors available and add 1
NPROC = $(shell echo $(shell nproc)+1 | bc)

.PHONY: all version build run save test tag_latest clean-docker-stopped-containers clean-docker-untagged-images

all: build

version:
	@echo Docker image version: $(VERSION)

build: version
	docker build -t $(NAME):$(VERSION) --build-arg makemt=$(NPROC) --build-arg nmos_cpp_version=$(NMOS_CPP_VERSION) .

run: build
	docker run -d -it --net=host --name $(NAME) --rm $(NAME):$(VERSION)

start: run
	docker attach $(NAME)

log:
	docker logs -f $(NAME)-registry

save: build
	docker save $(NAME):$(VERSION)| gzip > $(NAME)_$(VERSION).img.tar.gz

tag_latest: version
	docker tag $(NAME):$(VERSION) $(NAME):latest

clean: clean-docker-stopped-containers clean-docker-untagged-images
	echo DONE

clean-docker-stopped-containers:
	docker ps -aq --no-trunc | xargs docker rm

clean-docker-untagged-images:
	docker images -q --filter dangling=true | xargs docker rmi
