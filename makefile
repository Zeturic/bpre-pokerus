#!/usr/bin/env make

ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM")
endif

include $(DEVKITARM)/base_tools
include config.mk

# ------------------------------------------------------------------------------

SRC_FILES = $(wildcard src/*.c)
OBJ_FILES = $(SRC_FILES:src/%.c=build/src/%.o)
MAIN_ASM_INCLUDES = $(wildcard *.s)

CFLAGS = -O2 -mlong-calls -Wall -Wextra -mthumb -mno-thumb-interwork -fno-inline -fno-builtin -std=gnu11 -mabi=apcs-gnu -mcpu=arm7tdmi -march=armv4t -mtune=arm7tdmi -x c -c -I include -I gflib $(POKERUS_SPECIAL_CFLAGS)

LD = $(PREFIX)ld
LDFLAGS = --relocatable -T rom.ld

SIZE = $(PREFIX)size
SIZEFLAGS = -d -B

PREPROC = tools/preproc/preproc
SCANINC = tools/scaninc/scaninc

TOOLS = $(PREPROC) $(SCANINC)

ARMIPS ?= armips
ARMIPS_FLAGS = -sym test.sym $(POKERUS_SPECIAL_ARMIPS_FLAGS)

PYTHON ?= python
FREESIA = $(PYTHON) tools/freesia
FREESIAFLAGS = --rom rom.gba --start-at $(START_AT)

START_AT ?= 0x0871A240
INSERT_POKERUS_SPECIAL ?= true
Special_IsPokerusInParty ?= 0x133

ifeq ($(INSERT_POKERUS_SPECIAL),true)
POKERUS_SPECIAL_CFLAGS = -D INSERT_POKERUS_SPECIAL=
POKERUS_SPECIAL_ARMIPS_FLAGS = -equ INSERT_POKERUS_SPECIAL 1 -equ Special_IsPokerusInParty $(Special_IsPokerusInParty)
else
POKERUS_SPECIAL_CFLAGS = 
POKERUS_SPECIAL_ARMIPS_FLAGS = -equ INSERT_POKERUS_SPECIAL 0
endif

# ------------------------------------------------------------------------------

.PHONY: all spotless clean clean-tools repoint-cursor-options md5

all: test.gba

spotless: clean clean-tools

clean:
	rm -rf build test.gba test.sym

clean-tools:
	+BUILD_TOOLS_TARGET=clean ./build_tools.sh

repoint-cursor-options:
	$(ARMIPS) repoint-cursor-options.asm

md5: test.gba
	@md5sum test.gba

# ------------------------------------------------------------------------------

$(TOOLS):
	+./build_tools.sh

build/src/%.o: src/%.c charmap.txt $(PREPROC)
	@mkdir -p build/src
	(echo '#line 1 "$<"' && $(PREPROC) "$<" charmap.txt) | $(CC) $(CFLAGS) -o "$@" -

build/linked.o: $(OBJ_FILES) rom.ld
	@mkdir -p build
	$(LD) $(LDFLAGS) $(OBJ_FILES) -o "$@"

test.gba: rom.gba main.asm build/linked.o $(MAIN_ASM_INCLUDES)
	$(eval NEEDED_BYTES = $(shell PATH="$(PATH)" $(SIZE) $(SIZEFLAGS) build/linked.o |  awk 'FNR == 2 {print $$4}'))
	$(ARMIPS) $(ARMIPS_FLAGS) main.asm -definelabel allocation $(shell $(FREESIA) $(FREESIAFLAGS) --needed-bytes $(NEEDED_BYTES)) -equ allocation_size $(NEEDED_BYTES)

build/dep/src/%.d: src/%.c $(SCANINC)
	@mkdir -p build/dep/src
	@$(SCANINC) -I include $< | awk '{print "$(<:src/%.c=build/src/%.o) $@ : "$$0}' > "$@"

include $(SRC_FILES:src/%.c=build/dep/src/%.d)
