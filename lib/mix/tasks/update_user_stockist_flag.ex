defmodule Mix.Tasks.UpdateUserStockistFlag do
  @moduledoc """
  Mix task to update a user's is_stockist flag.

  ## Usage

      mix update_user_stockist_flag <username> <true|false>

  ## Examples

      mix update_user_stockist_flag beta_tester false
      mix update_user_stockist_flag john_doe true

  """

  use Mix.Task

  alias CommerceFront.Settings

  @shortdoc "Update a user's is_stockist flag"

  def run([username, value]) do
    Mix.Task.run("app.start")

    is_stockist_value =
      case value do
        "true" -> true
        "false" -> false
        _ ->
          IO.puts("Error: value must be 'true' or 'false'")
          System.halt(1)
      end

    IO.puts("Updating user '#{username}' is_stockist flag to #{is_stockist_value}...")

    case Settings.update_user_stockist_flag(username, is_stockist_value) do
      {:ok, user} ->
        IO.puts("Success! User #{user.username} is_stockist flag updated to #{user.is_stockist}")

      {:error, reason} ->
        IO.puts("Error: #{reason}")
        System.halt(1)
    end
  end

  def run(_) do
    IO.puts("""
    Usage: mix update_user_stockist_flag <username> <true|false>

    Examples:
      mix update_user_stockist_flag beta_tester false
      mix update_user_stockist_flag john_doe true
    """)

    System.halt(1)
  end
end
