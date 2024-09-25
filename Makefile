@PHONY: dev
dev:; gleam run -m lustre/dev start

@PHONY: release # minified
release:; gleam run -m lustre/dev build --minify=true
