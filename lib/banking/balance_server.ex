defmodule Banking.BalanceServer do
  use GenServer

  alias Banking.UserRegistry
  alias Banking.UserRequestCounter
  alias Banking.Utils

  defmodule BalanceStruct do
    defstruct [:amount, :currency]
  end

  def start_link(user) do
    UserRequestCounter.add_user(user)
    GenServer.start_link(__MODULE__, user, name: via_tuple(user))
  end

  def get_balance(user, currency) do
    user |> UserRegistry.lookup!() |> GenServer.call({:get_balance, currency})
  end

  def deposit(user, amt, currency) do
    user |> UserRegistry.lookup!() |> GenServer.call({:deposit, amt, currency})
  end

  def withdraw(user, amt, currency) do
    user |> UserRegistry.lookup!() |> GenServer.call({:withdraw, amt, currency})
  end

  defp via_tuple(user) do
    {:via, Registry, {Banking.UserRegistry, user}}
  end

  # ------ server callbacks -------

  def init(user) do
    IO.puts("Starting GenServer for User: #{user} ")
    {:ok, []}
  end

  def handle_call({:get_balance, currency}, _from, state) do
    amt =
      Enum.find_value(state, 0.0, fn x ->
        if x.currency == currency, do: Utils.to_amt(x.amount)
      end)

    {:reply, {:ok, amt}, state}
  end

  def handle_call({:deposit, amt, currency}, _from, state) do
    case Enum.split_with(state, &(&1.currency == currency)) do
      {[], _} ->
        amt = Utils.to_amt(amt)
        newstate = [%BalanceStruct{amount: amt, currency: currency} | state]
        {:reply, {:ok, amt}, newstate}

      {[object], remaining_state} ->
        newamt = Utils.to_amt(object.amount + amt)
        object = Map.replace(object, :amount, newamt)
        newstate = [object | remaining_state]
        {:reply, {:ok, newamt}, newstate}
    end
  end

  def handle_call({:withdraw, amt, currency}, _from, state) do
    case Enum.split_with(state, &(&1.currency == currency)) do
      {[], _} ->
        {:reply, {:error, :zero_balance}, state}

      {[object], remaining_state} ->
        if amt > object.amount do
          {:reply, {:error, :not_sufficient_balance}, state}
        else
          object = Map.replace(object, :amount, Utils.to_amt(object.amount - amt))
          {:reply, {:ok, object.amount}, [object | remaining_state]}
        end
    end
  end
end
