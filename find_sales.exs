
import Ecto.Query
alias CommerceFront.Repo
alias CommerceFront.Settings.User
alias CommerceFront.Settings.Sale

user = Repo.get_by(User, username: "beta_tester")

if user do
  IO.puts("Found user: #{user.username} (ID: #{user.id})")
  
  sales = Repo.all(
    from s in Sale,
    where: s.user_id == ^user.id,
    order_by: [desc: s.inserted_at],
    limit: 5
  )

  if Enum.empty?(sales) do
    IO.puts("No sales found for user.")
  else
    IO.puts("Recent sales:")
    Enum.each(sales, fn sale ->
      IO.puts("Date: #{sale.sale_date}, Total: #{sale.grand_total}, Status: #{sale.status}, ID: #{sale.id}")
    end)
  end
else
  IO.puts("User 'beta_tester' not found.")
end
