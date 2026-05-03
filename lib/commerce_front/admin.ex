defmodule CommerceFront.Admin do
  @moduledoc """
  Admin module for executing Elixir code with Code.eval.
  All executed commands are logged for audit purposes.
  """

  require Logger

  @doc """
  Evaluates Elixir code string and returns the result.
  All executions are logged with timestamp and code for audit trail.
  
  Automatically imports Ecto.Query and aliases CommerceFront.Repo for convenience.

  ## Parameters
    - code: String containing Elixir code to evaluate
    - env: Map containing execution environment (optional)

  ## Returns
    {:ok, result} on success
    {:error, error_message} on failure
  """
  def eval_code(code, env \\ %{}) when is_binary(code) do
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()

    # Log the execution for audit purposes
    Logger.info("[ADMIN_CODE_EVAL] timestamp=#{timestamp} code_length=#{byte_size(code)}")

    # Log the actual code (be careful with sensitive data in production)
    Logger.debug("[ADMIN_CODE_EVAL] code=#{code}")

    try do
      # Prepend common imports/aliases for database queries
      preamble = """
      import Ecto.Query
      alias CommerceFront.Repo
      """
      
      full_code = preamble <> "\n" <> code
      
      # Evaluate the code with the provided environment
      {result, _binding} = Code.eval_string(full_code, [], __ENV__)
      
      Logger.info("[ADMIN_CODE_EVAL] timestamp=#{timestamp} status=success")
      
      {:ok, result}
    rescue
      e ->
        error_message = "#{inspect(e.__struct__)}: #{Exception.message(e)}"
        Logger.error("[ADMIN_CODE_EVAL] timestamp=#{timestamp} status=error message=#{error_message}")
        {:error, error_message}
    end
  end

  @doc """
  Executes a database query through Ecto.Repo.
  This is a safer wrapper that ensures we're working with the repo.

  ## Parameters
    - repo_module: The Ecto.Repo module (e.g., CommerceFront.Repo)
    - query_fn: Anonymous function that takes repo as argument and returns query result

  ## Example
      Admin.exec_db_query(CommerceFront.Repo, fn repo ->
        repo.get(CommerceFront.User, user_id)
      end)
  """
  def exec_db_query(repo_module, query_fn) when is_function(query_fn, 1) do
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()
    Logger.info("[ADMIN_DB_QUERY] timestamp=#{timestamp} repo=#{inspect(repo_module)}")

    try do
      result = query_fn.(repo_module)
      Logger.info("[ADMIN_DB_QUERY] timestamp=#{timestamp} status=success")
      {:ok, result}
    rescue
      e ->
        error_message = "#{inspect(e.__struct__)}: #{Exception.message(e)}"
        Logger.error("[ADMIN_DB_QUERY] timestamp=#{timestamp} status=error message=#{error_message}")
        {:error, error_message}
    end
  end

  @doc """
  Retrieves recent admin execution logs.
  """
  def get_recent_logs(limit \\ 50) do
    # This would typically query a logs table
    # For now, we'll just return a placeholder
    {:ok, %{limit: limit, message: "Log retrieval not implemented - check application logs"}}
  end
end
