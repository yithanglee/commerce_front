defmodule Mix.Tasks.UpdateUserStockist do
  @moduledoc """
  Mix task to update a user's is_stockist field to true.

  ## Usage

  Update the beta_tester user (default):
      mix update_user_stockist

  Update a specific user by email:
      mix update_user_stockist --email user@example.com

  ## Options

  - `--email` - The email of the user to update (defaults to "beta_tester@example.com")
  """

  use Mix.Task

  @shortdoc "Updates a user's is_stockist field to true"

  def run(args) do
    # Ensure the application is started
    Mix.Task.run("app.start")

    {opts, _, _} = OptionParser.parse(args, strict: [email: :string])

    email = opts[:email] || "beta_tester@example.com"

    case update_user_stockist(email) do
      {:ok, user} ->
        IO.puts("✓ Successfully updated user #{user.email} (id: #{user.id})")
        IO.puts("  is_stockist: #{user.is_stockist}")

      {:error, reason} ->
        IO.puts("✗ Error: #{reason}")
        Mix.raise("Failed to update user stockist status")
    end
  end

  defp update_user_stockist(email) do
    alias CommerceFront.Repo
    alias CommerceFront.Settings.User

    case Repo.get_by(User, email: email) do
      nil ->
        {:error, "User with email #{email} not found"}

      user ->
        case Repo.update(User.changeset(user, %{is_stockist: true})) do
          {:ok, updated_user} ->
            {:ok, updated_user}

          {:error, changeset} ->
            errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
            {:error, "Failed to update user: #{inspect(errors)}"}
        end
    end
  end
end
