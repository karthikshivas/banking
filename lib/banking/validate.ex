defmodule Banking.Validate do
  @moduledoc """
  This module is used to validate arguments of functions
  """

  @doc """
  Validating user arguments where user value should be string

  Returns true when user value is string

    iex> Banking.Validate.create_user_args("user1")
    true

  Returns error when user value is any type other than string

    iex> Banking.Validate.create_user_args(:user1)
    {:error, :argument_error}

  """
  def create_user_args(user) do
    with false <- is_bitstring(user) do
      {:error, :argument_error}
    end
  end

  @doc """

  Returns true when user value is string and currency is string

    iex> Banking.Validate.balance_args("user1", "usd")
    true

  Returns error when user value or currency is any type other than string

    iex> Banking.Validate.balance_args(:user1, "usd")
    {:error, :argument_error}

    iex> Banking.Validate.balance_args("user1", 1)
    {:error, :argument_error}

  """
  def balance_args(user, currency) do
    with false <- is_valid_user_arg?(user) and is_valid_currency_arg?(currency) do
      {:error, :argument_error}
    end
  end

  @doc """

  Returns true when user value is string, currency is string and amt is
  non negative number else return error

    iex> Banking.Validate.deposit_withdraw_args("user1", 100, "usd")
    true

    iex> Banking.Validate.deposit_withdraw_args(:user1, 100, "usd")
    {:error, :argument_error}

    iex> Banking.Validate.deposit_withdraw_args("user1", 100, 1)
    {:error, :argument_error}

    iex> Banking.Validate.deposit_withdraw_args("user1", "100", "usd")
    {:error, :argument_error}

  """
  def deposit_withdraw_args(user, amt, currency) do
    with false <-
           is_valid_user_arg?(user) and is_valid_amt_arg?(amt) and
             is_valid_currency_arg?(currency) do
      {:error, :argument_error}
    end
  end

  @doc """

  Returns true when users value is string, currency is string and amt is
  non negative number else return error

    iex> Banking.Validate.fund_transfer_args("user1", "user2", 100, "usd")
    true

    iex> Banking.Validate.fund_transfer_args("user1", :user2, 100, "usd")
    {:error, :argument_error}

    iex> Banking.Validate.fund_transfer_args("user1", "user2", 100, 1)
    {:error, :argument_error}

    iex> Banking.Validate.fund_transfer_args("user1", "user2", "100", "usd")
    {:error, :argument_error}

  """
  def fund_transfer_args(user1, user2, amt, currency) do
    with false <-
           is_valid_user_arg?(user1) and is_valid_user_arg?(user2) and is_valid_amt_arg?(amt) and
             is_valid_currency_arg?(currency) do
      {:error, :argument_error}
    end
  end

  def is_valid_user_arg?(user) do
    is_bitstring(user)
  end

  def is_valid_amt_arg?(amt) do
    is_number(amt) and amt >= 0
  end

  def is_valid_currency_arg?(currency) do
    is_bitstring(currency)
  end
end
