package sifive.freedom.sgx.min

import chisel3._
import freechips.rocketchip.config.Parameters
import freechips.rocketchip.devices.debug.JtagDTMKey
import freechips.rocketchip.diplomacy.{FixedClockResource, LazyModule}
import freechips.rocketchip.jtag.JTAGIO
import freechips.rocketchip.util.SyncResetSynchronizerShiftReg

import sifive.blocks.devices.gpio.{GPIOPins, PeripheryGPIOKey}
import sifive.blocks.devices.pinctrl.BasePin

//-------------------------------------------------------------------------
// Platform IO
//-------------------------------------------------------------------------
class PlatformIO(implicit val p: Parameters) extends Bundle {
  val jtag = Flipped(new JTAGIO(hasTRSTn = false))
  val jtag_reset = Input(Bool())
  val gpio = new GPIOPins(() => new BasePin(), p(PeripheryGPIOKey)(0))

  val uart_rx = Input(Bool())
  val uart_tx = Output(Bool())
}

//-------------------------------------------------------------------------
// Intel SGX System Developer Kit
//-------------------------------------------------------------------------
class Platform(implicit p: Parameters) extends Module {
  val sys = Module(LazyModule(new System).module)
  override val io = IO(new PlatformIO)

  val sjtag = sys.debug.systemjtag.get
  sjtag.reset := io.jtag_reset
  sjtag.mfr_id := p(JtagDTMKey).idcodeManufId.U(11.W)
  sjtag.jtag <> io.jtag
  io.gpio <> sys.gpio.head

  // UART
  io.uart_tx := sys.uart(0).txd
  sys.uart(0).rxd := RegNext(RegNext(io.uart_rx))
}
