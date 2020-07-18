package sifive.freedom.sgx.min

import chisel3._
import chisel3.core.withClockAndReset
import freechips.rocketchip.config.Parameters
import shell.intel.sgxMinShell
import sifive.fpgashells.ip.intel.{IBUF, IOBUF}

//-------------------------------------------------------------------------
// Intel SGX System Developer Kit
//-------------------------------------------------------------------------
class FPGAChip(override implicit val p: Parameters) extends sgxMinShell {
  withClockAndReset(cpu_clock, cpu_rst) {
    val dut = Module(new Platform)

    dut.io.jtag.TCK := jtag_tck
    IBUF(dut.io.jtag.TDI, jtag_tdi)
    IOBUF(jtag_tdo, dut.io.jtag.TDO)
    IBUF(dut.io.jtag.TMS, jtag_tms)
    dut.io.jtag_reset := jtag_rst

    IBUF(dut.io.uart_rx, uart_rx)
    uart_tx := dut.io.uart_tx

    Seq(led_0, led_1, led_2, led_3) zip dut.io.gpio.pins foreach {
      case (led, pin) =>
        led := ~Mux(pin.o.oe, pin.o.oval, false.B)
    }

    dut.io.gpio.pins.foreach(_.i.ival := false.B)
    IBUF(dut.io.gpio.pins(4).i.ival, key1)
    IBUF(dut.io.gpio.pins(5).i.ival, key2)
  }
  cpu_clock <> clk25
}
