defmodule UserRequestCounterTest do
  use ExUnit.Case

  alias Banking.UserRegistry

  @user1 "user1"
  @user2 "user2"
  @currency "usd"

  setup_all do
    {:ok, _pid} = UserRegistry.create_user(@user1)
    {:ok, _pid} = UserRegistry.create_user(@user2)

    on_exit(fn ->
      UserRegistry.delete_user(@user1)
      UserRegistry.delete_user(@user2)
    end)
  end

  describe "manage user request" do
    test "if the request count is more than two for a user send error" do
      IO.puts("manage user request test starting...")
      task1 = Task.async(fn -> Banking.deposit(@user1, 100, @currency) end)
      task2 = Task.async(fn -> Banking.get_balance(@user1, @currency) end)
      Process.sleep(100)
      task3 = Task.async(fn -> Banking.get_balance(@user1, @currency) end)

      assert {:ok, 100.00} == Task.await(task1)
      assert {:ok, 100.00} == Task.await(task2)
      assert {:error, :user_request_count_exceeded} == Task.await(task3)
    end
  end
end
