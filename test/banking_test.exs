defmodule BankingTest do
  use ExUnit.Case
  doctest Banking.Validate

  alias Banking.UserRegistry

  @user1 "user1"
  @user2 "user2"
  @currency "usd"
  @amount 15.50

  describe "create_user/1" do
    test "create_user" do
      user = @user1
      {:ok, pid} = UserRegistry.create_user(user)
      assert {:ok, pid} == UserRegistry.lookup(user)
      UserRegistry.delete_user(user)
    end
  end

  describe "deposit/3" do
    setup do
      {:ok, _pid} = UserRegistry.create_user(@user1)

      on_exit(fn -> UserRegistry.delete_user(@user1) end)
    end

    test "Amount Deposit to User account" do
      assert {:ok, 15.50} == Banking.deposit(@user1, @amount, @currency)
    end
  end

  describe "withdraw/3" do
    setup do
      {:ok, _pid} = UserRegistry.create_user(@user1)
      {:ok, _amt} = Banking.deposit(@user1, @amount, @currency)

      on_exit(fn -> UserRegistry.delete_user(@user1) end)
    end

    test "Withdraw Amount from User Account" do
      assert {:ok, 10.50} == Banking.withdraw(@user1, 5.00, @currency)
    end
  end

  describe "fund_transfer/4" do
    setup do
      {:ok, _pid1} = UserRegistry.create_user(@user1)
      {:ok, _pid2} = UserRegistry.create_user(@user2)
      {:ok, 15.50} = Banking.deposit(@user1, @amount, @currency)

      on_exit(fn ->
        UserRegistry.delete_user(@user1)
        UserRegistry.delete_user(@user2)
      end)
    end

    test "Fund Transfer from user1 account to user2 account" do
      {:ok, :fund_transfer_successful} = Banking.fund_transfer(@user1, @user2, 10.00, @currency)

      assert {:ok, 10.00} == Banking.get_balance(@user2, @currency)
      assert {:ok, 5.50} == Banking.get_balance(@user1, @currency)
    end
  end
end
