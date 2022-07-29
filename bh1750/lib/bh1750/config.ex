defmodule BH1750.Config do
  @moduledoc """
  A struct to contain configuration settings for a BH1750 sensor.
  """
  use TypedStruct

  @type addr :: 0x23 | 0x5C
  @type mode :: :high | :high2 | :low
  @type freq :: :cont | :once

  typedstruct do
    field :addr, addr(), default: 0x23
    field :mode, mode(), default: :high
    field :freq, freq(), default: :cont
  end

  def new, do: struct(__MODULE__)
  def new(opts), do: struct(__MODULE__, opts)

  @spec opcode(t()) :: <<_::16>>
  def opcode(%__MODULE__{mode: mode, freq: freq}) do
    <<freq_to_bin(freq), mode_to_bin(mode)>>
  end

  defp freq_to_bin(:cont), do: 0b0001
  defp freq_to_bin(:once), do: 0b0010

  defp mode_to_bin(:high), do: 0b0000
  defp mode_to_bin(:high2), do: 0b0001
  defp mode_to_bin(:low), do: 0b0011
end
