defmodule Banking.UserRequestCounter do
  @maximum_allowed_request Application.compile_env(:banking, :maximum_allowed_request)

  def create_user_request_counter(user) do
    with :undefined <- :ets.whereis(__MODULE__) do
      :ets.new(__MODULE__, [:public, :named_table])
      :ets.insert(__MODULE__, {user, 0})
    end
  end

  def delete_user_request_counter(user) do
    :ets.delete(__MODULE__, user)
  end

  def add_user(user) do
    with :undefined <- :ets.whereis(__MODULE__) do
      create_user_request_counter(user)
    else
      _ ->
        with [] <- :ets.lookup(__MODULE__, user) do
          :ets.insert(__MODULE__, {user, 0})
        end
    end
  end

  def increment_counter(user) do
    :ets.update_counter(__MODULE__, user, {2, 1})
  end

  def decrement_counter(user) do
    :ets.update_counter(__MODULE__, user, {2, -1})
  end

  def validate_user_request_count(user, type \\ nil) do
    count =
      case :ets.lookup(__MODULE__, user) do
        [{_user, count}] ->
          count

        [] ->
          :ets.insert(__MODULE__, {user, 0})
          0

        _ ->
          add_user(user)
          0
      end

    if count >= @maximum_allowed_request do
      {:error, user_request_count_error(type)}
    else
      true
    end
  end

  defp user_request_count_error(:sender) do
    :sender_request_count_exceeded
  end

  defp user_request_count_error(:receiver) do
    :receiver_request_count_exceeded
  end

  defp user_request_count_error(_) do
    :user_request_count_exceeded
  end
end
