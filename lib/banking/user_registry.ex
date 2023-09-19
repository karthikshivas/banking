defmodule Banking.UserRegistry do
  alias Banking.UserRegistry
  alias Banking.UserRequestCounter
  alias Banking.Types

  @spec create_user(user :: Types.user()) :: any()
  def create_user(user) do
    DynamicSupervisor.start_child(Banking.UserSupervisor, {Banking.BalanceServer, user})
  end

  @spec lookup(user :: Types.user()) :: {:ok, pid()} | {:error, String.t()}
  def lookup(user) do
    case Registry.lookup(__MODULE__, user) do
      [{pid, _}] -> {:ok, pid}
      _ -> {:error, "User does not exist #{user}"}
    end
  end

  def lookup!(user) do
    with [{pid, _}] <- Registry.lookup(__MODULE__, user) do
      pid
    end
  end

  def delete_user(user) do
    UserRequestCounter.delete_user_request_counter(user)
    {:ok, pid} = UserRegistry.lookup(user)
    DynamicSupervisor.terminate_child(Banking.UserSupervisor, pid)
  end
end
