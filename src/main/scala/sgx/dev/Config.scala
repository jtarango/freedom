package sifive.freedom.sgx.dev

import freechips.rocketchip.config.Config
import freechips.rocketchip.devices.debug.{JtagDTMConfig, JtagDTMKey}
import freechips.rocketchip.devices.tilelink.{DevNullParams, MaskROMParams, PeripheryMaskROMKey}
import freechips.rocketchip.diplomacy.{AddressSet, DTSTimebase, RegionType}
import freechips.rocketchip.subsystem._
// DualCoreConfig, TinyConfig, RoccExampleConfig
import freechips.rocketchip.system.{BaseConfig, TinyConfig, RoccExampleConfig}
import freechips.rocketchip.tile.XLen

import sifive.blocks.devices.gpio.{GPIOParams, PeripheryGPIOKey}
import sifive.blocks.devices.spi.{PeripherySPIKey, SPIParams}
import sifive.blocks.devices.uart.{PeripheryUARTKey, UARTParams}

import sifive.freedom.unleashed.DevKitFPGAFrequencyKey
import Config._

object Config {
  val ClockMHz = 25.0

  val defaultJTAGConfig = new JtagDTMConfig (
    idcodeVersion = 2,
    idcodePartNum = 0xe31,
    idcodeManufId = 0x489,
    debugIdleCycles = 5)
}

class TinySGXConfig extends Config (
    new WithNBreakpoints(2)      ++
    new WithNExtTopInterrupts(0) ++
    new WithJtagDTM              ++
    new TinyConfig 
)

class MiddleSGXConfig extends Config (
    new WithNBreakpoints(2)      ++
    new WithNExtTopInterrupts(0) ++
    new WithJtagDTM              ++
    new WithNBigCores(1)         ++
    new WithJtagDTM              ++
    new BaseConfig
)

class BigSGXConfig extends Config (
    new WithExtMemSize(1l << 30) ++
    new WithNMemoryChannels(1) ++
    new WithCacheBlockBytes(16) ++
    new WithNBigCores(1) ++
    new WithJtagDTM ++
    new BaseConfig
)

class TinyPeripherals extends Config((site, here, up) => {
  case PeripheryGPIOKey => List(
    GPIOParams(address = BigInt(0x64002000L), width = 6)
  )
  case PeripheryMaskROMKey => List(
    MaskROMParams(address = 0x10000, name = "BootROM")
  )
  case PeripheryUARTKey => List(
    UARTParams(address = BigInt(0x64000000L))
  )  
  case DevKitFPGAFrequencyKey => ClockMHz
  case SystemBusKey => up(SystemBusKey).copy(
    errorDevice = Some(DevNullParams(
      Seq(AddressSet(0x3000, 0xfff)),
      maxAtomic=site(XLen)/8,
      maxTransfer=128,
      region = RegionType.TRACKED)))
  case PeripheryBusKey =>
    up(PeripheryBusKey, site).copy(frequency = (ClockMHz * 1000000).toInt, errorDevice = None)  
})

class MiddlePeripherals extends Config((site, here, up) => {
  case PeripheryGPIOKey => List(
    GPIOParams(address = BigInt(0x64002000L), width = 6)
  )
  case PeripheryMaskROMKey => List(
    MaskROMParams(address = 0x10000, name = "BootROM")
  )
  case PeripheryUARTKey => List(
    UARTParams(address = BigInt(0x64000000L))
  )
  case DevKitFPGAFrequencyKey => ClockMHz
  case SystemBusKey => up(SystemBusKey).copy(
    errorDevice = Some(DevNullParams(
      Seq(AddressSet(0x3000, 0xfff)),
      maxAtomic=site(XLen)/8,
      maxTransfer=128,
      region = RegionType.TRACKED)))
  case PeripheryBusKey =>
    up(PeripheryBusKey, site).copy(frequency = (ClockMHz * 1000000).toInt, errorDevice = None)
})

class BigPeripherals extends Config((site, here, up) => {
  case PeripheryGPIOKey => List(
    GPIOParams(address = BigInt(0x64002000L), width = 6)
  )
  case PeripheryMaskROMKey => List(
    MaskROMParams(address = 0x10000, name = "BootROM")
  )
  case PeripherySPIKey => List(
    SPIParams(rAddress = BigInt(0x64001000L))
  )
  case PeripheryUARTKey => List(
    UARTParams(address = BigInt(0x64000000L))
  )
  case DevKitFPGAFrequencyKey => ClockMHz
  case SystemBusKey => up(SystemBusKey).copy(
    errorDevice = Some(DevNullParams(
      Seq(AddressSet(0x3000, 0xfff)),
      maxAtomic=site(XLen)/8,
      maxTransfer=128,
      region = RegionType.TRACKED)))
  case PeripheryBusKey =>
    up(PeripheryBusKey, site).copy(frequency = (ClockMHz * 1000000).toInt, errorDevice = None)
})

class DefaultTinySGXConfig extends Config(
  new TinyPeripherals    ++
    new TinySGXConfig().alter((site, here, up) => {
      case JtagDTMKey => Config.defaultJTAGConfig
    })
)

class DefaultMiddleSGXConfig extends Config(
  new MiddlePeripherals    ++
    new MiddleSGXConfig().alter((site, here, up) => {
      case JtagDTMKey => Config.defaultJTAGConfig
    })
)

class DefaultBigSGXConfig extends Config(
  new BigPeripherals    ++
    new BigSGXConfig().alter((site, here, up) => {
      case JtagDTMKey => Config.defaultJTAGConfig
    })
)

class DefaultSGXConfig extends Config(
  new BigPeripherals    ++
    new BigSGXConfig().alter((site, here, up) => {
      case JtagDTMKey => Config.defaultJTAGConfig
    })
)


