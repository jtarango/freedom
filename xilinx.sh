make -f Makefile.e300artydevkit verilog mcs 2>&1 | tee xilinxe300artydevkitBuildLog.txt
make -f Makefile.vc707-iofpga verilog mcs 2>&1 | tee xilinxvc707-iofpgaBuildLog.txt
make -f Makefile.vc707-u500devkit verilog mcs 2>&1 | tee xilinxu500devkitBuildLog.txt
make -f Makefile.vcu118-iofpga verilog mcs 2>&1 | tee xilinxvcu118-iofpgaBuildLog.txt
make -f Makefile.vcu118-iofpga-nvdla verilog mcs 2>&1 | tee xilinxvcu118-iofpga-nvdlaBuildLog.txt
make -f Makefile.vcu118-u500devkit verilog mcs 2>&1 | tee xilinxvcu118-u500devkitBuildLog.txt
make -f Makefile.veraiofpga verilog mcs 2>&1 | tee xilinxveraiofpgaBuildLog.txt


