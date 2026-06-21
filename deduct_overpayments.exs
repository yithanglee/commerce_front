# deduct_overpayments.exs
# Run as: mix run deduct_overpayments.exs
# Or to commit: mix run deduct_overpayments.exs --commit

alias CommerceFront.Settings
alias CommerceFront.Repo

overpayments = [
  %{id: 39109, user_id: 49, wallet_type: "bonus", amount: 171.52},
  %{id: 39108, user_id: 49, wallet_type: "bonus", amount: 171.52},
  %{id: 39107, user_id: 49, wallet_type: "bonus", amount: 171.52},
  %{id: 39106, user_id: 60, wallet_type: "product", amount: 25.73},
  %{id: 39105, user_id: 60, wallet_type: "bonus", amount: 231.55},
  %{id: 39104, user_id: 60, wallet_type: "product", amount: 6.43},
  %{id: 39103, user_id: 60, wallet_type: "bonus", amount: 57.89},
  %{id: 39102, user_id: 1130, wallet_type: "product", amount: 6.43},
  %{id: 39101, user_id: 1130, wallet_type: "bonus", amount: 57.89},
  %{id: 39100, user_id: 1140, wallet_type: "product", amount: 6.43},
  %{id: 39099, user_id: 1140, wallet_type: "bonus", amount: 57.89},
  %{id: 39098, user_id: 1107, wallet_type: "product", amount: 6.43},
  %{id: 39097, user_id: 1107, wallet_type: "bonus", amount: 57.89}
]

commit? = false

IO.puts("=== E-Wallet Overpayment Deduction Script ===")

if commit? do
  IO.puts("MODE: COMMIT (Changes WILL be saved to the database)")
else
  IO.puts("MODE: DRY RUN (No changes will be saved)")
end

IO.puts("=============================================\n")

# Group by user and wallet type to calculate aggregate changes and current balances
deductions_by_wallet =
  overpayments
  |> Enum.group_by(fn item -> {item.user_id, item.wallet_type} end)

# Display current status
IO.puts(
  String.pad_trailing("User ID", 10) <>
    String.pad_trailing("Wallet Type", 15) <>
    String.pad_trailing("Current Bal", 15) <>
    String.pad_trailing("To Deduct", 15) <>
    "Expected Bal"
)

IO.puts(String.duplicate("-", 67))

Enum.each(deductions_by_wallet, fn {{user_id, wallet_type}, items} ->
  current_bal = Settings.wallet_available_balance(user_id, wallet_type) |> IO.inspect()
  total_deduction = items |> Enum.map(& &1.amount) |> Enum.sum() |> Float.round(2) |> IO.inspect()
  expected_bal = (current_bal - total_deduction) |> Float.round(2) |> IO.inspect()
end)

IO.puts("\n" <> String.duplicate("=", 67) <> "\n")

if commit? do
  IO.puts("Starting deductions...")

  results =
    Repo.transaction(fn ->
      Enum.reduce(overpayments, [], fn item, acc ->
        deduction_amount = -item.amount
        remarks = "Deduction for overpayment of transaction ID #{item.id}"

        params = %{
          user_id: item.user_id,
          amount: deduction_amount,
          remarks: remarks,
          wallet_type: item.wallet_type
        }

        case Settings.create_wallet_transaction(params) do
          {:ok, transaction} ->
            IO.puts(
              "SUCCESS: Deducted -#{item.amount} from User #{item.user_id}'s #{item.wallet_type} wallet (Txn Ref: #{item.id})"
            )

            [transaction | acc]

          {:error, reason} ->
            IO.puts(
              "ERROR: Failed to deduct from User #{item.user_id}'s #{item.wallet_type} wallet (Txn Ref: #{item.id}). Reason: #{inspect(reason)}"
            )

            Repo.rollback(reason)
        end
      end)
    end)

  case results do
    {:ok, _} ->
      IO.puts("\nAll overpayment deductions successfully processed and committed!")

    {:error, reason} ->
      IO.puts("\nTransaction rolled back. No changes made. Error: #{inspect(reason)}")
  end
else
  IO.puts("Dry run completed. To apply these changes, run the script with the `--commit` flag:")
  IO.puts("  mix run deduct_overpayments.exs --commit")
end
