# See LICENSE for license details.

# Required variables:
# - MODEL
# - PROJECT
# - CONFIG_PROJECT
# - CONFIG
# - BUILD_DIR
# - FPGA_DIR

# Optional variables:
# - EXTRA_FPGA_VSRCS

#ALTERAD_LICENSE_FILE=1800@altera02p.elic.intel.com:1800@altera05p.elic.intel.com
#export ALTERAD_LICENSE_FILE
#export ALTERAPATH="/opt/intel/FPGA_pro/20.2"
#export INTELFPGAOCLSDKROOT="/opt/intel/FPGA_pro/20.2/hld"
#export ALTERAOCLSDKROOT="${ALTERAPATH}/hld"
#export QSYS_ROOTDIR="/opt/intel/FPGA_pro/20.2/qsys/bin"
#export QUARTUS_ROOTDIR=${ALTERAPATH}/quartus
#export QUARTUS_ROOTDIR_OVERRIDE="$QUARTUS_ROOTDIR"
#export PATH=$PATH:${ALTERAPATH}/quartus/bin
#export PATH=$PATH:${ALTERAPATH}/nios2eds/bin
#export PATH=$PATH:${ALTERAPATH}/modelsim_ase/bin
#export PATH=$PATH:${ALTERAPATH}/quartus/sopc_builder/bin
#export PATH=$PATH:${QSYS_ROOTDIR}
#
#export JAVA_HOME=/opt/jdk1.8.0_192
#export PATH=${PATH}:${JAVA_HOME}/bin
#export RISCV_GCCHOME=/opt/RISC-V/tools/riscv64-unknown-elf-gcc-8.2.0-2019.02.0-x86_64-linux-ubuntu14
#export RISCV_OCDHOME=/opt/RISC-V/riscv-openocd-0.10.0-2019.02.0-x86_64-linux-ubuntu14
#export RISCV=${RISCV_GCCHOME}
#export RISCV_OPENOCD=${RISCV_OCDHOME}

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

.PHONY: romgen
romgen: $(romgen)
	srec_cat -Output $(BUILD_DIR)/bootrom.mif -Memory_Initialization_File 32 $(BUILD_DIR)/sdboot.bin -Binary -Output_Block_Size 128

f := $(BUILD_DIR)/$(CONFIG_PROJECT).$(CONFIG).vsrcs.F
$(f):
	echo $(VSRCS) > $@

$(info DEBUG SOURCE is $(VSRCS))


 .PHONY: mcs
mcs: map fit asm sta smart

###################################################################
# Copy over project files
###################################################################
COPYASSIGNPATH = $(FPGA_DIR)
copy:
	cp -f $(COPYASSIGNPATH)/$(QSF_IFILE) $(FPGA_BUILD_DIR)/$(IQSF_OFILE)
	cp -f $(COPYASSIGNPATH)/$(SDC_IFILE) $(FPGA_BUILD_DIR)/$(ISDC_OFILE)

ASSIGNMENT_FILES = $(FPGA_BUILD_DIR)/$(QSF_OFILES) $(FPGA_BUILD_DIR)/$(SDC_OFILES)

###################################################################
# Executable Configuration
###################################################################
MAP_ARGS = --family=$(FPGA_FAMILY)  --read_settings_files=on
FIT_ARGS = --part=$(FPGA_DEVICE)  --read_settings_files=on
ASM_ARGS =
STA_ARGS =

BUILDER_PREFIX = $(FPGA_DIR)/$(BOARD)/$(CONFIG_PROJECT)

###################################################################
# Build Target
###################################################################
SMARTPATH=$(BUILD_DIR)

map: $(SMARTPATH)/smart.log $(BUILDER_PREFIX).map.rpt
fit: $(SMARTPATH)/smart.log $(BUILDER_PREFIX).fit.rpt
asm: $(SMARTPATH)/smart.log $(BUILDER_PREFIX).asm.rpt
sta: $(SMARTPATH)/smart.log $(BUILDER_PREFIX).sta.rpt
smart: $(SMARTPATH)/smart.log

.PHONY: $(MODEL)
###################################################################
# Target implementations
###################################################################
# Quartus build process from the --help=makefiles option.
STAMP = echo done >

# Note Changed from quartus_map $(MAP_ARGS) $(MODEL)
# quartus_ipgenerate --quartus-project="${top}".qpf --clear-output-directory "${top}".qsys --upgrade-ip-cores [glob -directory $ipdir [file join * {*.xci}]]
$(BUILDER_PREFIX).map.rpt: $(BUILDER_PREFIX).map.chg $(SOURCE_FILES) 
	quartus_syn $(MODEL) --recompile --analysis_and_elaboration
	$(STAMP) $(BUILDER_PREFIX).fit.chg

$(BUILDER_PREFIX).fit.rpt: $(BUILDER_PREFIX).fit.chg $(BUILDER_PREFIX).map.rpt
	quartus_fit $(FIT_ARGS) $(MODEL)
	$(STAMP) $(BUILDER_PREFIX).asm.chg
	$(STAMP) $(BUILDER_PREFIX).sta.chg

$(BUILDER_PREFIX).asm.rpt: $(BUILDER_PREFIX).asm.chg $(BUILDER_PREFIX).fit.rpt
	quartus_asm $(ASM_ARGS) $(MODEL)

$(BUILDER_PREFIX).sta.rpt: $(FPGA_BUILD_DIR).sta.chg $(BUILDER_PREFIX).fit.rpt
	quartus_sta $(STA_ARGS) $(MODEL)

$(SMARTPATH)/smart.log: $(ASSIGNMENT_FILES)
	quartus_sh --determine_smart_action $(MODEL) > $(SMARTPATH)/smart.log


SDC_INFILE = $(FPGA_DIR)/$(BOARD)/$(SDC_IFILE)
QSF_INFILE = $(FPGA_DIR)/$(BOARD)/$(QSF_IFILE)
QSF_OUTFILE = $(BUILD_DIR)/$(CONFIG_PROJECT).$(QSF_OFILE)

$(info DEBUG INFO SCD IN is $(SDC_INFILE))
$(info DEBUG INFO QSF IN is $(QSF_INFILE))
$(info DEBUG INFO QSF OUT is $(QSF_OUTFILE))

###################################################################
# Project initialization
#  Quartus forces us to keep the list of all the source files in 
#  the .qsf file.
###################################################################
$(ASSIGNMENT_FILES):
	rm -f $(QSF_OUTFILE)
	touch $(SMARTPATH)/smart.log
	quartus_sh --prepare -f $(FPGA_FAMILY) -d $(FPGA_DEVICE) -t $(BOARD)
	echo >> $(QSF_OUTFILE)
	echo "set_global_assignment -name TOP_LEVEL_ENTITY " $(MODEL) >> $(QSF_OUTFILE)
	echo "# Source files" >> $(QSF_OUTFILE)
	echo "set_global_assignment -name VERILOG_FILE " $(CONFIG_PROJECT).$(CONFIG).v >> $(QSF_OUTFILE)
	for x in $(SOURCE_FILES); do \
	    $(info DEBUG INFO X is $(x)) \
		case $${x##*.} in \
			v|V)       echo set_global_assignment -name VERILOG_FILE $$x >> $(QSF_OUTFILE) ;;\
			sv|SV)     echo set_global_assignment -name SYSTEMVERILOG_FILE $$x >> $(QSF_OUTFILE) ;;\
			vhd|VHD)   echo set_global_assignment -name VHDL_FILE $$x >> $(QSF_OUTFILE) ;;\
			qsys|QSYS) echo set_global_assignment -name  QSYS_FILE $$x >> $(QSF_OUTFILE) ;;\
			scd|SCD)   echo set_global_assignment -name  SDC_FILE $$x >> $(QSF_OUTFILE) ;;\
			tcl|TCL)   echo set_global_assignment -name  TCL_FILE $$x >> $(QSF_OUTFILE) ;;\
			stp|STP)   echo set_global_assignment -name  SIGNALTAP_FILE $$x >> $(QSF_OUTFILE) ;;\
			qip|QIP)   echo set_global_assignment -name QIP_FILE $$x >> $(QSF_OUTFILE) ;;\
			*) echo set_global_assignment -name SOURCE_FILE $$x >> $(QSF_OUTFILE) ;;\
		esac; \
	done
	echo >> $(QSF_OUTFILE)
	echo "# SDC files" >> $(QSF_OUTFILE)
	for x in $(SDC_INFILE); do echo set_global_assignment -name SDC_FILE $$x >> $(QSF_OUTFILE); done
	for x in $(QSF_INFILE); do printf "\n#\n# Included QSF file $$x\n#\n" >> $(QSF_OUTFILE); cat $$x >> $(QSF_OUTFILE); done	

$(BUILDER_PREFIX).map.chg:
	$(STAMP) $(BUILDER_PREFIX).map.chg
$(BUILDER_PREFIX).fit.chg:
	$(STAMP) $(BUILDER_PREFIX).fit.chg
$(BUILDER_PREFIX).sta.chg:
	$(STAMP) $(BUILDER_PREFIX).sta.chg
$(BUILDER_PREFIX).asm.chg:
	$(STAMP) $(BUILDER_PREFIX).asm.chg

#bit := $(BUILD_DIR)/obj/$(MODEL).bit
#$(bit): $(romgen) $(f)
#	cd $(BUILD_DIR); vivado \
#		-nojournal -mode batch \
#		-source $(fpga_common_script_dir)/vivado.tcl \
#		-tclargs \
#		-top-module "$(MODEL)" \
#		-F "$(f)" \
#		-ip-vivado-tcls "$(shell find '$(BUILD_DIR)' -name '*.vivado.tcl')" \
#		-board "$(BOARD)"
#
# Build .mcs
#mcs := $(BUILD_DIR)/obj/$(MODEL).mcs
#$(mcs): $(bit)
#	cd $(BUILD_DIR); vivado -nojournal -mode batch -source $(fpga_common_script_dir)/write_cfgmem.tcl -tclargs $(BOARD) $@ $<
#
#.PHONY: mcs
#mcs: $(mcs)
#
# Build Libero project
#prjx := $(BUILD_DIR)/libero/$(MODEL).prjx
#$(prjx): $(verilog)
#	cd $(BUILD_DIR); libero SCRIPT:$(fpga_common_script_dir)/libero.tcl SCRIPT_ARGS:"$(BUILD_DIR) $(MODEL) $(PROJECT) $(CONFIG) $(BOARD)"
#
#.PHONY: prjx
#prjx: $(prjx)

# Clean
.PHONY: clean
clean:
ifneq ($(BOOTROM_DIR),"")
	$(MAKE) -C $(BOOTROM_DIR) clean
endif
	$(MAKE) -C $(FPGA_DIR) clean
	rm -rf $(BUILD_DIR)
