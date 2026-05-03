# User Stockist Flag Update - Implementation Summary

## Overview
This implementation provides a **safe, auditable way** to update a user's `is_stockist` flag in the commerce_front application through a Mix task that can be run from the server environment.

## Files Changed

### 1. `lib/commerce_front/settings.ex`
Added a new function `update_user_stockist_flag/2` that:
- Looks up a user by username
- Updates their `is_stockist` field using the existing Ecto changeset
- Returns `{:ok, user}` on success or `{:error, reason}` on failure

```elixir
def update_user_stockist_flag(username, is_stockist_value) do
  user = get_user_by_username(username)

  if user == nil do
    {:error, "User not found"}
  else
    User.changeset(user, %{is_stockist: is_stockist_value}) |> Repo.update()
  end
end
```

### 2. `lib/mix/tasks/update_user_stockist_flag.ex` (NEW)
Created a Mix task that provides a CLI interface for updating the stockist flag.

## Usage

### From the Server (Recommended)
```bash
cd /path/to/commerce_front

# Set to false (remove stockist status)
mix update_user_stockist_flag beta_tester false

# Set to true (grant stockist status)
mix update_user_stockist_flag john_doe true
```

### How It Works
1. The Mix task starts the application (`app.start`)
2. Validates the input parameters
3. Calls `CommerceFront.Settings.update_user_stockist_flag/2`
4. Reports success or failure with clear messages

## Safety Features

✅ **No direct database credentials needed** - Uses the application's existing Repo and changeset validation
✅ **Auditable** - Can be run from CI or admin environment with logging
✅ **Validation** - Uses existing User.changeset which enforces all business rules
✅ **Error handling** - Returns clear error messages for invalid usernames
✅ **Idempotent** - Safe to run multiple times with the same value

## Alternative: API Endpoint (If Needed)

If you need to update this via the web interface, you could add an admin-only endpoint to `api_controller.ex`:

```elixir
def post(conn, %{"scope" => "admin_update_stockist"} = params) do
  # Requires admin authentication
  case Settings.update_user_stockist_flag(params["username"], params["is_stockist"]) do
    {:ok, user} ->
      json(conn, %{status: "ok", user: BluePotion.sanitize_struct(user)})
    {:error, reason} ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(500, Jason.encode!(%{status: "error", reason: reason}))
  end
end
```

Then call via:
```bash
curl -X POST http://localhost:4001/api/admin \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <admin_token>" \
  -d '{"scope": "admin_update_stockist", "username": "beta_tester", "is_stockist": false}'
```

## Testing

Before running on production:

1. **Test on development database:**
   ```bash
   mix update_user_stockist_flag test_user false
   ```

2. **Verify the change:**
   ```bash
   # Connect to database and check
   psql -d commerce_front_dev -c "SELECT username, is_stockist FROM users WHERE username = 'test_user';"
   ```

3. **Check application logs** for the transaction record

## Notes

- The `is_stockist` field is a boolean with default `false` (see `user.ex` schema)
- Related fields: `stockist_fee_perc` (default 0.03), `stockist_user_id`
- Users with `is_stockist: true` can have associated `stockist_users` (users linked via `stockist_user_id`)
- The changeset validates required fields but `is_stockist` is optional, making this update safe

## Rollback

To revert the change, simply run the same command with the opposite value:
```bash
mix update_user_stockist_flag beta_tester true
```
