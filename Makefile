.PHONY: $(ALL_DEST) release debug universal clean help

BUILD_DIR := .build
BIN_DIR := bin
BIN_NAME := scrub

ALL_DEST := x86_64 arm64

debug: BUILD_CONF := debug
debug: universal

release: BUILD_CONF := release
release: universal

universal: $(ALL_DEST)
	$(eval UNIVERSAL_OUT := $(BIN_DIR)/$(BUILD_CONF)/universal)
	mkdir -p $(UNIVERSAL_OUT)
	lipo -create -output $(UNIVERSAL_OUT)/$(BIN_NAME) \
		$(BIN_DIR)/$(BUILD_CONF)/x86_64/$(BIN_NAME) \
		$(BIN_DIR)/$(BUILD_CONF)/arm64/$(BIN_NAME)

$(ALL_DEST):
	$(eval OUT_DIR := $(BIN_DIR)/$(BUILD_CONF)/$@)
	swift build -c $(BUILD_CONF) --arch $@
	mkdir -p $(OUT_DIR)
	cp $(BUILD_DIR)/$@-apple-macosx/$(BUILD_CONF)/$(BIN_NAME) $(OUT_DIR)

clean:
	rm -rf $(BUILD_DIR) $(BIN_DIR)

help:
	@echo "make debug		build with debug configuration"
	@echo "make release		build with release configuration"
	@echo "make clean		clean build related directories"
	@echo "make help		show this guide"

