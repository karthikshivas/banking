defmodule Banking do
  @moduledoc """
  Documentation for `Banking. Creating User account state, depositing amount,
  withdrawing amount and fund transfer between two users`.
  """

  alias Banking.BalanceServer
  alias Banking.{Types, UserRegistry, UserRequestCounter, Validate}

  @enable_user_request_delay Application.compile_env(:banking, :enable_user_request_delay)

  @spec create_user(Types.user()) :: any()
  def create_user(user) do
    with true <- Validate.create_user_args(user),
         [] <- Registry.lookup(UserRegistry, user) do
      UserRegistry.create_user(user)
    end
  end

  @spec deposit(Types.user(), Types.amount(), Types.currency()) :: any()
  def deposit(user, amt, currency) do
    with true <- Validate.deposit_withdraw_args(user, amt, currency),
         {:ok, _pid} <- UserRegistry.lookup(user),
         true <- UserRequestCounter.validate_user_request_count(user) do
      UserRequestCounter.increment_counter(user)
      add_user_request_delay()

      try do
        BalanceServer.deposit(user, amt, currency)
      rescue
        err -> reraise err, __STACKTRACE__
      after
        UserRequestCounter.decrement_counter(user)
      end
    end
  end

  @spec withdraw(Types.user(), Types.amount(), Types.currency()) ::
          {:ok, Types.amount()} | {:error, any()}
  def withdraw(user, amt, currency) do
    with true <- Validate.deposit_withdraw_args(user, amt, currency),
         {:ok, _pid} <- UserRegistry.lookup(user),
         true <- UserRequestCounter.validate_user_request_count(user) do
      UserRequestCounter.increment_counter(user)
      add_user_request_delay()

      try do
        BalanceServer.withdraw(user, amt, currency)
      rescue
        err -> reraise err, __STACKTRACE__
      after
        UserRequestCounter.decrement_counter(user)
      end
    end
  end

  @spec get_balance(Types.user(), Types.currency()) :: {:ok, Types.amount()} | {:error, any()}
  def get_balance(user, currency) do
    with true <- Validate.balance_args(user, currency),
         {:ok, _pid} <- UserRegistry.lookup(user),
         true <- UserRequestCounter.validate_user_request_count(user) do
      UserRequestCounter.increment_counter(user)
      add_user_request_delay()

      try do
        BalanceServer.get_balance(user, currency)
      rescue
        err -> reraise err, __STACKTRACE__
      after
        UserRequestCounter.decrement_counter(user)
      end
    end
  end

  @spec fund_transfer(Types.user(), Types.user(), Types.amount(), Types.currency()) ::
          {:ok, atom()} | {:error, any()}
  def fund_transfer(sender, receiver, amt, currency) do
    with true <- Validate.fund_transfer_args(sender, receiver, amt, currency),
         {:ok, _pid} <- UserRegistry.lookup(sender),
         {:ok, _pid} <- UserRegistry.lookup(receiver),
         true <- UserRequestCounter.validate_user_request_count(sender, :sender),
         true <- UserRequestCounter.validate_user_request_count(receiver, :receiver) do
      UserRequestCounter.increment_counter(sender)
      UserRequestCounter.increment_counter(receiver)

      try do
        {:ok, senderbalance} = withdraw(sender, amt, currency)

        case deposit(receiver, amt, currency) do
          {:ok, receiverbalance} ->
            IO.puts(
              "Fund Transfer successful. Sender Balance: #{senderbalance}, Receiver Balance: #{receiverbalance}"
            )

            {:ok, :fund_transfer_successful}

          _ ->
            # Redeposit amt withdrawn from Sender
            deposit(sender, amt, currency)
            {:error, :fund_transfer_failed}
        end
      rescue
        err -> reraise err, __STACKTRACE__
      after
        UserRequestCounter.decrement_counter(sender)
        UserRequestCounter.decrement_counter(receiver)
      end
    end
  end

  def add_user_request_delay() do
    if @enable_user_request_delay do
      Process.sleep(1000)
    end
  end
end
