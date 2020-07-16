###################################################################
# Project Name: SGX
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

###################################################################
base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
BUILD_DIR := $(base_dir)/builds/sgx-dev
FPGA_DIR := $(base_dir)/fpga-shells/intel
PROJECT := sifive.freedom.sgx.dev
MODEL := FPGAChip
export CONFIG_PROJECT := sifive.freedom.sgx.dev
export CONFIG := DefaultSGXConfig
export BOARD := sgx
export BOOTROM_DIR := $(base_dir)/bootrom/sdboot

rocketchip_dir := $(base_dir)/rocket-chip
sifiveblocks_dir := $(base_dir)/sifive-blocks
#VSRCS := \
#	$(rocketchip_dir)/src/main/resources/vsrc/AsyncResetReg.v \
#	$(rocketchip_dir)/src/main/resources/vsrc/plusarg_reader.v \
#	$(sifiveblocks_dir)/vsrc/SRLatch.v \
#	$(FPGA_DIR)/common/vsrc/PowerOnResetFPGAOnly.v \
#	$(FPGA_DIR)/$(BOARD)/vsrc/sdio.v \
#	$(FPGA_DIR)/$(BOARD)/vsrc/SGXreset.v \
#	$(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).rom.v \
#	$(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).v
#include alteraCommon.mk

FPGA_TOP = $(MODEL)
FPGA_FAMILY = "Stratix V"
FPGA_DEVICE = 5SGXEA7N2F45C2
# SYN_FILES = rtl/fpga.v rtl/clocks.v
# QSF_FILES = $(FPGA_DIR)/$(BOARD)/s10_fpga_golden_top.qsf
# SDC_FILES = fpga.sdc

# Joseph Tarango
# FPGA settings
FPGA_TOP = fpga
FPGA_FAMILY = "Stratix X"
FPGA_DEVICE = 1SG280HU2F50E2VG

# Files for synthesis
SYN_FILES = rtl/fpga.v
SYN_FILES += rtl/fpga_core.v
SYN_FILES += rtl/debounce_switch.v
SYN_FILES += rtl/sync_reset.v
SYN_FILES += rtl/sync_signal.v
SYN_FILES += rtl/i2c_master.v
SYN_FILES += rtl/si570_i2c_init.v
SYN_FILES += lib/eth/rtl/eth_mac_10g_fifo.v
SYN_FILES += lib/eth/rtl/eth_mac_10g.v
SYN_FILES += lib/eth/rtl/axis_xgmii_rx_64.v
SYN_FILES += lib/eth/rtl/axis_xgmii_tx_64.v
SYN_FILES += lib/eth/rtl/lfsr.v
SYN_FILES += lib/eth/rtl/eth_axis_rx_64.v
SYN_FILES += lib/eth/rtl/eth_axis_tx_64.v
SYN_FILES += lib/eth/rtl/udp_complete_64.v
SYN_FILES += lib/eth/rtl/udp_checksum_gen_64.v
SYN_FILES += lib/eth/rtl/udp_64.v
SYN_FILES += lib/eth/rtl/udp_ip_rx_64.v
SYN_FILES += lib/eth/rtl/udp_ip_tx_64.v
SYN_FILES += lib/eth/rtl/ip_complete_64.v
SYN_FILES += lib/eth/rtl/ip_64.v
SYN_FILES += lib/eth/rtl/ip_eth_rx_64.v
SYN_FILES += lib/eth/rtl/ip_eth_tx_64.v
SYN_FILES += lib/eth/rtl/ip_arb_mux.v
SYN_FILES += lib/eth/rtl/arp_64.v
SYN_FILES += lib/eth/rtl/arp_cache.v
SYN_FILES += lib/eth/rtl/arp_eth_rx_64.v
SYN_FILES += lib/eth/rtl/arp_eth_tx_64.v
SYN_FILES += lib/eth/rtl/eth_arb_mux.v
SYN_FILES += lib/eth/rtl/xgmii_interleave.v
SYN_FILES += lib/eth/rtl/xgmii_deinterleave.v
SYN_FILES += lib/eth/lib/axis/rtl/arbiter.v
SYN_FILES += lib/eth/lib/axis/rtl/priority_encoder.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_fifo.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_fifo.v
SYN_FILES += lib/eth/lib/axis/rtl/axis_async_fifo_adapter.v
SYN_FILES += cores/phy/phy.qip
SYN_FILES += cores/phy_reconfig/phy_reconfig.qip


all: verilog
	$(MAKE) -C $(BOOTROM_DIR) clean romgen || true
	srec_cat -Output $(BUILD_DIR)/xip.hex -Intel $(BUILD_DIR)/xip.bin -Binary -Output_Block_Size 128
        # srec_cat -Output $(BUILD_DIR)/bootrom.mif -Memory_Initialization_File 32 $(BUILD_DIR)/sdboot.bin -Binary -Output_Block_Size 128

include altera.mk
