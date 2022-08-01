defmodule SensorHub.Sensor do
  defstruct [:name, :fields, :read, :convert]

  def new(name) do
    %__MODULE__{
      read: read_fn(name),
      convert: convert_fn(name),
      fields: fields(name),
      name: name
    }
  end

  def measure(%__MODULE__{} = sensor) do
    sensor.read.()
    |> sensor.convert.()
  end

  def fields(BH1750), do: [:light_lumens]
  def fields(BMP280), do: [:altitude_m, :pressure_pa, :temperature_c]
  def fields(SGP30), do: [:co2_eq_ppm, :tvoc_ppb]

  def read_fn(BH1750), do: fn -> BH1750.measure() end
  def read_fn(BMP280), do: fn -> BMP280.measure(BMP280) end
  def read_fn(SGP30), do: fn -> SGP30.state() end

  def convert_fn(BH1750) do
    fn data -> %{light_lumens: data} end
  end
  
  def convert_fn(BMP280) do
    fn reading ->
      case reading do
        {:ok, measurement} ->
          Map.take(measurement, [:altitude_m, :pressure_pa, :temperature_c])

        _ ->
          %{}
      end
    end
  end

  def convert_fn(SGP30) do
    fn reading ->
      Map.take(reading, [:co2_eq_ppm, :tvoc_ppb])
    end
  end
end
