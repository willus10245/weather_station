defmodule BH1750 do
  use GenServer

  require Logger

  alias BH1750.{Comm, Config}
  
  @power_off <<0b0000>>
  @power_on <<0b0001>>
  @reset <<0b0111>>

  def start_link(options \\ %{}) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def measure do
    GenServer.call(__MODULE__, :get_measurement)
  end

  @impl GenServer
  def init(%{address: address, i2c_bus_name: bus_name} = args) do
    i2c_bus = Comm.open(bus_name)

    config =
      args
      |> Map.take([:mode, :freq])
      |> Config.new()

    Comm.write(i2c_bus, address, @power_on)
    :timer.sleep(200)
    Comm.write(i2c_bus, address, Config.opcode(config))
    :timer.send_interval(1_000, :measure)
    
    state = %{
      i2c_bus: i2c_bus,
      address: address,
      config: config,
      last_reading: :no_reading
    }

    {:ok, state}
  end

  def init(args) do
    {bus_name, address} = Comm.discover()
    transport = "bus: #{bus_name}, address: #{address}"
    
    Logger.info("Starting BH1750. Please specify an address and a bus.")
    Logger.info("Starting on " <> transport)

    defaults =
      args
      |> Map.put(:address, address)
      |> Map.put(:i2c_bus_name, bus_name)

    init(defaults)
  end

  @impl GenServer
  def handle_info(
    :measure,
    %{i2c_bus: i2c_bus, address: address} = state
  ) do
    last_reading = Comm.read(i2c_bus, address)
    
    {:noreply, %{state | last_reading: last_reading}}
  end

  @impl GenServer
  def handle_call(:get_measurement, _from, state) do
    {:reply, state.last_reading, state}
  end
end
