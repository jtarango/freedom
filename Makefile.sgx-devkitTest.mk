###################################################################
# Project Configuration: DK-DEV-1SGX-H-A
#
# Intel® Stratix® 10 GX FPGA Development Kit Versions
# Version Intel® Stratix® 10 GX FPGA H-Tile
# Ordering Code DK-DEV-1SGX-H-A
# Device Part Number 1SG280HU2F50E2VG
#  Specify the name of the design (project) and the Quartus II and settings file (.qsf)
# Installing Quartus 
#  https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/manual/quartus_install.pdf
# Introduction 
#  https://youtu.be/bwoyQ_RnaiA
#  https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/qts/qts_qii5v1.pdf
# Altera to Xilinx Map
#  https://www.intel.com/content/www/us/en/programmable/documentation/mtr1422491996806.html 
#  https://www.xilinx.com/support/documentation/sw_manuals/ug1192-xilinx-design-for-intel.pdf
#  https://rocketboards.org/foswiki/Documentation/S10SoCNewUsers
#  https://www.intel.com/content/www/us/en/programmable/education/webcasts/all/wc-2009-xilinx-ise-to-quartus-software.html
# Command line Scripting
#  https://youtu.be/01oz-hJ0mDU
# TCL Scripting 
#  https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/manual/tclscriptrefmnl.pdf
#  https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/hb/qts/qts_qii52003.pdf
#  https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/design-examples/design-software/tcl.html
#  generate_tcl_file <name> [-c | compile] [-s | simulate] [-b | build] [-w | overwrite]
# Reference Example 
#  https://github.com/mfischer/Altera-Makefile
# Timing Reference
#  https://www.intel.cn/content/dam/altera-www/global/zh_CN/pdfs/literature/wp/wp_timinganalysis.pdf
###################################################################
# Setup for Build
###################################################################
base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR := $(base_dir)/builds/sgx-dev
FPGA_DIR := $(base_dir)/fpga-shells/intel
PROJECT := sifive.freedom.sgx.dev
MODEL := FPGAChip
export CONFIG_PROJECT := sifive.freedom.sgx.dev
export CONFIG := DefaultSGXConfig
export BOARD := sgx-dev
export BOOTROM_DIR := $(base_dir)/bootrom/sdboot

rocketchip_dir := $(base_dir)/rocket-chip
sifiveblocks_dir := $(base_dir)/sifive-blocks

###################################################################
# Part, Family
###################################################################
FPGA_FAMILY='Stratix 10'
FPGA_DEVICE=1SG280HU2F50E2VG

###################################################################
# Pinout and timing
###################################################################
# QSF files
QSF_IFILE = top_fpga_.qsf # In file.
QSF_OFILE = $(CONFIG).qsf  # Out file.

# SDC files
SDC_IFILE = top_fpga_.sdc # In file.

# srec_cat -Output $(BUILD_DIR)/xip.hex -Intel $(BUILD_DIR)/xip.bin -Binary -Output_Block_Size 128

all: verilog
	$(MAKE) -C $(BOOTROM_DIR) clean romgen || true
	srec_cat -Output $(BUILD_DIR)/bootrom.mif -Memory_Initialization_File 32 $(BUILD_DIR)/sdboot.bin -Binary -Output_Block_Size 128

include altera.mk
