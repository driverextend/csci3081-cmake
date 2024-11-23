CMAKEFLAGS = --build build --parallel
BUILDDIR = build

.PHONY: all build rebuild run debug clean docs lint lintQ venv

# compiles both the web and service part of the project
all: build

# default cmake process
build:
	@cmake -B $(BUILDDIR) $(GENERATOR); cmake $(CMAKEFLAGS)

# cleans up and rebuilds the build directory
rebuild: CMAKEFLAGS += --clean-first
rebuild: build

# quick shortcut to run the project, will not recompile project if changes had been made
run: CMAKEFLAGS += --target run_app
run: build

# TODO: Add debug target in cmake
debug: CMAKEFLAGS += --target debug
debug: build

# cleans up the build directory
clean:
	rm -rf $(BUILD_DIR)

# generates doxygen files
docs:
	cd docs; doxygen Doxyfile; cd ..;

# runs cpplint
# this will be slow, but will give you total number of errors
lint:
ifeq ($(wildcard .venv/bin/.),)
	make venv
endif
	.venv/bin/cpplint --filter=-legal/copyright,-build/include,-build/namespaces,-runtime/explicit,-build/header_guard,-runtime/references,-runtime/threadsafe_fn $(shell find ./service/include/simulationmodel/ ./service/src/simulationmodel/ -type f -name '*.cc' -o -name '*.h')

# this will be much quicker, but you won't have the total number of errors at the end
lintQ:
ifeq ($(wildcard .venv/bin/.),)
	make venv
endif
	find ./service/include/simulationmodel/ ./service/src/simulationmodel/ -type f -name '*.cc' -o -name '*.h' | xargs -n 1 -P 128 .venv/bin/cpplint --filter=-legal/copyright,-build/include,-build/namespaces,-runtime/explicit,-build/header_guard,-runtime/references,-runtime/threadsafe_fn

venv:
	@echo "Installing venv..."
	@python3 -m venv .venv;
	@./.venv/bin/pip install cpplint
	@./.venv/bin/pip install clang-format
	@mkdir -p .vscode; touch .vscode/settings.json
	@echo '{"[cpp]": {"editor.defaultFormatter": "ms-vscode.cpptools"},"C_Cpp.clang_format_fallbackStyle": "Google", "C_Cpp.clang_format_path": "$(shell pwd)/.venv/bin/clang-format",}' > ./.vscode/settings.json
