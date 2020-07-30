# See LICENSE for license details.
#
# Required variables:
# - MODEL
# - PROJECT
# - CONFIG_PROJECT
# - CONFIG
# - BUILD_DIR
# - FPGA_DIR
#
# Optional variables:
# - EXTRA_FPGA_VSRCS
###################################################################
# export to bootloader
###################################################################
export ROMCONF=$(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).rom.conf

###################################################################
# export to fpga-shells
###################################################################
export FPGA_TOP_SYSTEM=$(MODEL)
export FPGA_BUILD_DIR=$(BUILD_DIR)/$(FPGA_TOP_SYSTEM)
# export fpga_common_script_dir=$(FPGA_DIR)/common/tcl
# export fpga_board_script_dir=$(FPGA_DIR)/$(BOARD)/tcl

export BUILD_DIR

EXTRA_FPGA_VSRCS ?=
PATCHVERILOG ?= ""
BOOTROM_DIR ?= ""

base_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export rocketchip_dir := $(base_dir)/rocket-chip
SBT ?= java -jar $(rocketchip_dir)/sbt-launch.jar ++2.12.4

###################################################################
# Build firrtl.jar and put it where chisel3 can find it.
###################################################################
FIRRTL_JAR ?= $(rocketchip_dir)/firrtl/utils/bin/firrtl.jar
FIRRTL ?= java -Xmx2G -Xss8M -XX:MaxPermSize=256M -cp $(FIRRTL_JAR) firrtl.Driver

$(FIRRTL_JAR): $(shell find $(rocketchip_dir)/firrtl/src/main/scala -iname "*.scala")
	$(MAKE) -C $(rocketchip_dir)/firrtl SBT="$(SBT)" root_dir=$(rocketchip_dir)/firrtl build-scala
	touch $(FIRRTL_JAR)
	mkdir -p $(rocketchip_dir)/lib
	cp -p $(FIRRTL_JAR) rocket-chip/lib
	mkdir -p $(rocketchip_dir)/chisel3/lib
	cp -p $(FIRRTL_JAR) $(rocketchip_dir)/chisel3/lib

###################################################################
# Build .fir
###################################################################
firrtl := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).fir
$(firrtl): $(shell find $(base_dir)/src/main/scala -name '*.scala') $(FIRRTL_JAR)
	mkdir -p $(dir $@)
	$(SBT) "runMain freechips.rocketchip.system.Generator $(BUILD_DIR) $(PROJECT) $(MODEL) $(CONFIG_PROJECT) $(CONFIG)"

.PHONY: firrtl
firrtl: $(firrtl)

###################################################################
# Build .v
###################################################################
verilog := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).v
$(verilog): $(firrtl) $(FIRRTL_JAR)
	$(FIRRTL) -i $(firrtl) -o $@ -X verilog
ifneq ($(PATCHVERILOG),"")
	$(PATCHVERILOG)
endif

.PHONY: verilog
verilog: $(verilog)

romgen := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).rom.v
$(romgen): $(verilog)
ifneq ($(BOOTROM_DIR),"")
	$(MAKE) -C $(BOOTROM_DIR) romgen
	mv $(BUILD_DIR)/rom.v $@
endif

###################################################################
# Build test binaries for development, leds, leds with DRAM, xip, 
#  bootrom.
###################################################################
ifndef BOOTROM_DIR
    export BOOTROM_DIR := $(base_dir)/bootrom/sdboot
endif

ifndef TESTROM_DIR
    export TESTROM_DIR := $(base_dir)/bootrom/xip
endif
ifndef DRAM_SUPPORT
    DRAM_SUPPORT = false
endif

.PHONY: romgen
romgen: $(romgen)
	$(MAKE) -C $(TESTROM_DIR) ASM_SRC=leds clean romgen || true
	srec_cat -Output $(BUILD_DIR)/leds.hex -Intel $(BUILD_DIR)/leds.bin -Memory_Initialization_File 32 $(BUILD_DIR)/leds.bin -Binary -Output_Block_Size 128
	$(MAKE) -C $(TESTROM_DIR) ASM_SRC=xip romgen || true	
	srec_cat -Output $(base_dir)/bootrom/xip/xip.hex -Intel $(BUILD_DIR)/xip.bin -Memory_Initialization_File 32 $(BUILD_DIR)/sdboot.bin -Binary -Output_Block_Size 128
	cp $(BUILD_DIR)/sdboot.bin $(DEST_DIR)
	$(MAKE) -C $(BOOTROM_DIR) clean romgen || true
	srec_cat -Output $(BUILD_DIR)/bootrom.mif -Memory_Initialization_File 32 $(BUILD_DIR)/sdboot.bin -Binary -Output_Block_Size 128	
	$(info Checking DRAM Support)
    ifeq ($(DRAM_SUPPORT), true)
        $(MAKE) -C $(TESTROM_DIR) ASM_SRC=ledsDRAM romgen || true
        srec_cat -Output $(BUILD_DIR)/ledsDRAM.hex -Intel $(BUILD_DIR)/leds.bin -Memory_Initialization_File 32 $(BUILD_DIR)/ledsDRAM.bin -Binary -Output_Block_Size 128
    endif

f := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).vsrcs.F
$(f):
	echo $(VSRCS) > $@

$(info File Sources - $(VSRCS))

###################################################################
# Copy files and run Intel FPGA generation process.
###################################################################
mcs: verilog romgen fpga_make 
.PHONY: mcs

fpga_make: verilog romgen
	$(CP) -fv $(VRC_FILES) $(DEST_DIR)
    $(MAKE) -C $(BUILD_DIR) $(FPGA_BASE_MAKE)
 .PHONY: fpga_make

###################################################################
# Copy files and run Intel FPGA generation process.
###################################################################
.PHONY: clean
clean:
ifneq ($(BOOTROM_DIR),"")
	$(MAKE) -C $(BOOTROM_DIR) clean
endif
	$(MAKE) -C $(FPGA_DIR) clean
	rm -rf $(BUILD_DIR)
