VERSION                := $(shell cat VERSION)
REGISTRY               := eu.gcr.io/gardener-project
PREFIX                 := alpine-iptables
ALPINE_IMAGE_REPOSITORY  := $(REGISTRY)/$(PREFIX)
ALPINE_IMAGE_TAG         := $(VERSION)

.PHONY: alpine-docker-image
alpine-docker-image:
	@docker build -t $(ALPINE_IMAGE_REPOSITORY):$(ALPINE_IMAGE_TAG) -f alpine/Dockerfile --rm .

.PHONY: docker-image
docker-image: alpine-docker-image

.PHONY: release
release: docker-image docker-login docker-push

.PHONY: docker-login
docker-login:
	@gcloud auth login

.PHONY: docker-push
docker-push:
	@if ! docker images $(ALPINE_IMAGE_REPOSITORY) | awk '{ print $$2 }' | grep -q -F $(ALPINE_IMAGE_TAG); then echo "$(ALPINE_IMAGE_REPOSITORY) version $(ALPINE_IMAGE_TAG) is not yet built. Please run 'make ALPINE-docker-image'"; false; fi
	@docker push $(ALPINE_IMAGE_REPOSITORY):$(ALPINE_IMAGE_TAG)

