defmodule CommerceFrontWeb.AdminController do
  use CommerceFrontWeb, :controller

  alias CommerceFront.Admin

  @doc """
  Admin endpoint for executing Elixir code.
  
  Expects JSON body with:
  - "code": String containing Elixir code to evaluate
  - "env": Optional map of environment variables
  
  Returns:
  - "result": The evaluation result
  - "status": "success" or "error"
  - "message": Error message if applicable
  """
  def eval(conn, %{"code" => code} = params) when is_binary(code) do
    # Check authorization - in production, verify admin token/session
    case authorize_admin(conn) do
      :authorized ->
        env = Map.get(params, "env", %{})
        
        {result, status, message} = 
          case Admin.eval_code(code, env) do
            {:ok, value} -> 
              {serialize_result(value), "success", "Code executed successfully"}
            {:error, error} -> 
              {nil, "error", error}
          end
        
        conn
        |> put_status(200)
        |> json(%{
          status: status,
          result: result,
          message: message,
          timestamp: DateTime.utc_now() |> DateTime.to_iso8601()
        })
      
      :unauthorized ->
        conn
        |> put_status(401)
        |> json(%{
          status: "error",
          message: "Unauthorized - Admin access required"
        })
    end
  end

  def eval(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{
      status: "error",
      message: "Missing required parameter: code"
    })
  end

  @doc """
  Execute database queries through the admin endpoint.
  
  Expects JSON body with:
  - "query": String containing Elixir code for database operation
  """
  def db_query(conn, %{"query" => query} = _params) when is_binary(query) do
    case authorize_admin(conn) do
      :authorized ->
        # Wrap the query to ensure it goes through our safe execution
        code = """
        fn repo ->
          #{query}
        end
        """
        
        {result, status, message} =
          case Admin.eval_code(code) do
            {:ok, query_fn} when is_function(query_fn) ->
              # Execute with repo - this is a simplified example
              # In production, you'd want to pass the actual repo module
              {:ok, query_fn}
            {:error, error} ->
              {:error, error}
          end
        
        conn
        |> put_status(200)
        |> json(%{
          status: status,
          result: serialize_result(result),
          message: message
        })
      
      :unauthorized ->
        conn
        |> put_status(401)
        |> json(%{
          status: "error",
          message: "Unauthorized - Admin access required"
        })
    end
  end

  def db_query(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{
      status: "error",
      message: "Missing required parameter: query"
    })
  end

  @doc """
  Get recent admin execution logs.
  """
  def logs(conn, _params) do
    case authorize_admin(conn) do
      :authorized ->
        limit = conn.params["limit"] || 50
        
        {:ok, logs} = Admin.get_recent_logs(limit)
        
        conn
        |> json(%{
          status: "success",
          logs: logs
        })
      
      :unauthorized ->
        conn
        |> put_status(401)
        |> json(%{
          status: "error",
          message: "Unauthorized - Admin access required"
        })
    end
  end

  # Private Functions

  defp authorize_admin(conn) do
    # TODO: Implement proper admin authentication
    # Options:
    # 1. Check for admin session/token in headers
    # 2. Verify API key with admin privileges
    # 3. Check user role from authentication plug
    
    # For development/testing, allow with a simple header check
    # In production, replace with proper authentication
    admin_token = get_req_header(conn, "x-admin-token")
    
    cond do
      # Check for development mode (insecure - for dev only!)
      Mix.env() == :dev -> :authorized
      
      # Check for valid admin token
      admin_token != [] && valid_admin_token?(hd(admin_token)) -> :authorized
      
      true -> :unauthorized
    end
  end

  defp valid_admin_token?(token) do
    # TODO: Implement proper token validation
    # This could check against a database or environment variable
    # For now, check against an environment variable
    expected_token = System.get_env("ADMIN_API_TOKEN")
    expected_token != nil && token == expected_token
  end

  defp serialize_result(result) do
    # Convert result to JSON-serializable format
    case Jason.encode(result) do
      {:ok, json} -> Jason.decode!(json)
      {:error, _} -> inspect(result)
    end
  rescue
    _ -> inspect(result)
  end
end
