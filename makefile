docker-sh: docker-build
	docker run -it swift-ci-image /bin/bash

docker-run: docker-build
	docker run --rm swift-ci-image

docker-build:
	docker build -t swift-ci-image .

install:
	swift run install

uninstall:
	rm `which swift-ci` \
	rm -r ~/.swift-ci
