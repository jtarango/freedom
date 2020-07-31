###################################################################
# Project Configuration: EP4CE115F23I7
#
# Intel® Cyclone IV E FPGA Development Kit Versions
# Version Intel® Cyclone IV E FPGA
# Device Part Number EP4CE115F23I7
###################################################################
# Setup for Build
###################################################################
base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
FPGA_BASE_MAKE=$(base_dir)/fpga-shells/intel/zeowaa-e115/Makefile
rocketchip_dir := $(base_dir)/rocket-chip
sifiveblocks_dir := $(base_dir)/sifive-blocks
BUILD_DIR := $(base_dir)/builds/zeowaa-e115
FPGA_DIR := $(base_dir)/fpga-shells/intel
MODEL := FPGAChip
PROJECT := sifive.freedom.zeowaa.e115
export CONFIG_PROJECT := sifive.freedom.zeowaa.e115
export CONFIG := DefaultZeowaaConfig
export BOARD := zeowaa
export BOOTROM_DIR := $(base_dir)/bootrom/sdboot
export TESTROM_DIR := $(base_dir)/$(base_dir)/bootrom/xip
DRAM_SUPPORT=false
###################################################################
# Part, Family
###################################################################
FPGA_FAMILY='Cyclone IV'
FPGA_DEVICE=EP4CE115F23I7

.DEFAULT_GOAL := all

all: verilog
	$(MAKE) -C $(BOOTROM_DIR) clean romgen
	srec_cat -Output $(BUILD_DIR)/bootrom.mif -Memory_Initialization_File 32 $(BUILD_DIR)/sdboot.bin -Binary -Output_Block_Size 128
	$(info Done generation in $(BUILD_DIR))

include altera.mk
