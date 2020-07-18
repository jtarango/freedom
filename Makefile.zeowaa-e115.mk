# See LICENSE for license details.

base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR := $(base_dir)/builds/zeowaa-e115
FPGA_DIR := $(base_dir)/fpga-shells/intel
MODEL := FPGAChip
PROJECT := sifive.freedom.zeowaa.e115
export CONFIG_PROJECT := sifive.freedom.zeowaa.e115
export CONFIG := DefaultZeowaaConfig
export BOARD := zeowaa
export BOOTROM_DIR := $(base_dir)/bootrom/sdboot

rocketchip_dir := $(base_dir)/rocket-chip
sifiveblocks_dir := $(base_dir)/sifive-blocks

all: verilog
	$(MAKE) -C $(BOOTROM_DIR) clean romgen
	srec_cat -Output $(BUILD_DIR)/bootrom.mif -Memory_Initialization_File 32 $(BUILD_DIR)/sdboot.bin -Binary -Output_Block_Size 128

include alteraCommon.mk
