.PHONY: clean manual
clean:
	rm version.txt

docker_images: Dockerfile Dockerfile_dev
	bash build_image.sh

version.txt: CITATION.cff
	grep -w "^version" CITATION.cff | sed "s/version: /v/g" > version.txt

validate_cff: CITATION.cff
	cffconvert --validate

manual:
	cd docs && sh create_manual.sh
