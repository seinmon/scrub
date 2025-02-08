.PHONY: debug release build clean help

BUILD_DIR := .build
BIN_DIR := bin

debug: BUILD_CONF := debug
debug: build

release: BUILD_CONF := release
release: build

build:
	$(eval OUT_DIR := $(BIN_DIR)/$(BUILD_CONF)/)
	swift build -c $(BUILD_CONF)
	mkdir -p $(OUT_DIR)
	cp $(BUILD_DIR)/$(BUILD_CONF)/scrub $(OUT_DIR)

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

help:
	@echo "make debug		build with debug configuration"
	@echo "make release		build with release configuration"
	@echo "make clean		clean build related directories"
	@echo "make help		show this guide"

