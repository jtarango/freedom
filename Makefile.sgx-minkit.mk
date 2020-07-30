###################################################################
# Project Configuration: DK-DEV-1SGX-H-A
#
# Intel® Stratix® 10 GX FPGA Development Kit Versions
# Version Intel® Stratix® 10 GX FPGA H-Tile
# Ordering Code DK-DEV-1SGX-H-A
# Device Part Number 1SG280HU2F50E2VG
###################################################################
# Setup for Build
###################################################################
base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
FPGA_BASE_MAKE=$(base_dir)/fpga-shells/intel/sgx-dev/basefiles/Makefile
rocketchip_dir := $(base_dir)/rocket-chip
sifiveblocks_dir := $(base_dir)/sifive-blocks
BUILD_DIR := $(base_dir)/builds/sgx-min
FPGA_DIR := $(base_dir)/fpga-shells/intel/sgx-dev
PROJECT := sifive.freedom.sgx.min
MODEL := FPGAChip
export CONFIG_PROJECT := sifive.freedom.sgx.min
# DefaultTinySGXConfig, DefaultMiddleSGXConfig, DefaultSGXConfig
export CONFIG := DefaultSGXConfig
export BOARD := sgx-dev
export BOOTROM_DIR := $(base_dir)/bootrom/sdboot
export TESTROM_DIR := $(base_dir)/$(base_dir)/bootrom/xip

###################################################################
# Part, Family
###################################################################
FPGA_FAMILY='Stratix 10'
FPGA_DEVICE=1SG280HU2F50E2VG

.DEFAULT_GOAL := all

all: verilog romgen
    $(info Done generation in $(BUILD_DIR))

include altera.mk
