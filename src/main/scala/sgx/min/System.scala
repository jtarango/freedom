package sifive.freedom.sgx.min

import chisel3._

import freechips.rocketchip.config.Parameters
import freechips.rocketchip.devices.debug.{HasPeripheryDebug, HasPeripheryDebugModuleImp}
import freechips.rocketchip.devices.tilelink.{HasPeripheryMaskROMSlave, PeripheryMaskROMKey}
import freechips.rocketchip.diplomacy.{FixedClockResource, Resource, ResourceAddress, ResourceBinding}
import freechips.rocketchip.subsystem.{RocketSubsystem, RocketSubsystemModuleImp}

import sifive.blocks.devices.gpio.{HasPeripheryGPIO, HasPeripheryGPIOModuleImp}
import sifive.blocks.devices.uart.{HasPeripheryUART, HasPeripheryUARTModuleImp}

//-------------------------------------------------------------------------
// Intel SGX System Developer Kit
//-------------------------------------------------------------------------

class System(implicit p: Parameters) extends RocketSubsystem
  with HasPeripheryMaskROMSlave
  with HasPeripheryDebug
  with HasPeripheryUART
  with HasPeripheryGPIO
{
  override lazy val module = new SystemModule(this)
}

class SystemModule[+L <: System](_outer: L)
  extends RocketSubsystemModuleImp(_outer)
    with HasPeripheryDebugModuleImp
    with HasPeripheryUARTModuleImp
    with HasPeripheryGPIOModuleImp
{
  // Reset vector is set to the location of the mask rom
  val maskROMParams = p(PeripheryMaskROMKey)
  global_reset_vector := maskROMParams(0).address.U
}
