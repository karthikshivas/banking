defmodule Banking.Utils do
  alias Banking.Types

  @spec to_amt(amt :: Types.amount()) :: float()
  def to_amt(amt) when is_integer(amt) do
    amt * 1.0
  end

  def to_amt(amt) when is_float(amt) do
    amt
  end

  def is_non_negative_amount(amt) do
    is_number(amt) and amt >= 0
  end
end
