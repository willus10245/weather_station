defmodule BH1750.Comm do
  alias Circuits.I2C
  use Bitwise

  require Logger

  def discover(possible_addresses \\ [0x23, 0x5C]) do
    I2C.discover_one!(possible_addresses)
  end

  def open(bus_name) do
    {:ok, bus_ref} = I2C.open(bus_name)

    bus_ref
  end

  def write(i2c_bus, sensor, opcode) do
    Logger.info("Writing: #{opcode |> inspect(base: :binary)}")
    I2C.write(i2c_bus, sensor, opcode)
  end

  def read(i2c_bus, sensor) do
    <<msb::integer, lsb::integer>> = I2C.read!(i2c_bus, sensor, 2)
    
    Logger.info("Reading: #{inspect(<<msb, lsb>>, base: :binary)}")

    ((msb <<< 4) + lsb) / 1.2
  end
end
