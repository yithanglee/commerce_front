defmodule CommerceFront do
  import Ecto.Query
  alias CommerceFront.{Settings, Repo}

  @moduledoc """
  CommerceFront keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  def encode_params(params) do
    encode_value = fn tuple ->
      case tuple do
        {key, value} when is_map(value) ->
          {key, URI.encode_query(value)}

        {key, value} ->
          {key, value}
      end
    end

    params
    |> Enum.map(&encode_value.(&1))
    |> URI.encode_query()
  end

  def _send_sqs(map \\ %{"scope" => "register", "name" => "John", "age" => 30}) do
    params =
      %{
        "Action" => "SendMessage",
        "MessageBody" => Jason.encode!(map)
      }
      |> IO.inspect()

    query_string =
      encode_params(params)
      |> IO.inspect()

    case HTTPoison.post(
           "http://localhost:9324/queue/queue1",
           query_string,
           [{"Content-Type", "application/x-www-form-urlencoded"}]
         ) do
      {:ok,
       %HTTPoison.Response{
         body: body
       } = _res} ->
        body |> IO.puts()

      _ ->
        nil
    end
  end

  @doc """

    CommerceFront.Settings.pay_unpaid_bonus(~D[2023-11-07], ["sharing bonus", "team bonus"])

  CommerceFront.daily_task(~D[2023-11-27])
  like everyday before 8am, you need to run this using yesterday's date...

  """
  def daily_task(date \\ Date.utc_today()) do
    IO.inspect("performing daily task... #{date} at #{NaiveDateTime.utc_now()}")
    preferred_date = NaiveDateTime.utc_now() |> NaiveDateTime.to_date() |> Date.add(-1)
    date = preferred_date
    IO.inspect("changed to... #{preferred_date} at #{NaiveDateTime.utc_now()}")
    {y, m, d} = preferred_date |> Date.to_erl()
    end_of_month = Timex.end_of_month(date)
    CommerceFront.Calculation.daily_team_bonus(date)
    # can only run once
    CommerceFront.Settings.carry_forward_entry(date)
    # this will form the weak leg
      # "sharing bonus",
      # "stockist register bonus",
      # "drp sales level bonus"
    CommerceFront.Settings.pay_unpaid_bonus(date, [
      
      "team bonus"
    ])

    if end_of_month == date do
      CommerceFront.Calculation.matching_bonus(m, y)
      CommerceFront.Calculation.elite_leader(m, y)
      CommerceFront.Calculation.travel_fund(m, y)

      CommerceFront.Settings.pay_unpaid_bonus(date, [
        "matching bonus",
        "elite leader",
        "travel fund"
      ])

      CommerceFront.Calculation.repurchase_bonus(m, y)

      CommerceFront.Settings.pay_unpaid_bonus(date, ["repurchase bonus"])
    end
  end

  def daily_calculations(date \\ Date.utc_today()) do
    {y, m, d} = date |> Date.to_erl()
    CommerceFront.Calculation.daily_team_bonus(date)
    CommerceFront.Calculation.matching_bonus(m, y)
    CommerceFront.Calculation.elite_leader(m, y)
    CommerceFront.Calculation.travel_fund(m, y)
  end

  def monthly_calculations(date \\ Date.utc_today()) do
    {y, m, d} = date |> Date.to_erl()
    end_of_month = Timex.end_of_month(date)
    CommerceFront.Calculation.matching_bonus(m, y)
    CommerceFront.Calculation.elite_leader(m, y)
    CommerceFront.Calculation.travel_fund(m, y)

    CommerceFront.Settings.pay_unpaid_bonus(date, [
      "matching bonus",
      "elite leader",
      "travel fund"
    ])

    CommerceFront.Calculation.repurchase_bonus(m, y)

    CommerceFront.Settings.pay_unpaid_bonus(date, ["repurchase bonus"])
  end

  def carry_forward_task(sdate \\ ~D[2024-04-04], edate \\ Date.utc_today() |> Date.add(-1)) do
    for date <- Date.range(sdate, edate) do
      CommerceFront.Settings.reconstruct_daily_group_sales_summary(date)

      CommerceFront.Calculation.daily_team_bonus(date)
      CommerceFront.Settings.carry_forward_entry(date)
    end
  end

  def populate_member_data(country_name) do
    rows = File.read!("h4.csv") |> String.split("\n") |> Enum.reject(&(&1 == "")) |> IO.inspect()

    for sample <- rows do
      [sponsor, username, _placement, direction, fullname] = sample |> String.split(",")

      dir =
        if direction == "L" do
          "left"
        else
          "right"
        end

      params =
        %{
          "ic_no" => "0",
          "email" => "0@gmail.com",
          "fullname" => fullname,
          "password" => username,
          "phone" => "0",
          "rank_id" => 4,
          "sponsor" => sponsor,
          "username" => username,
          "placement" => %{"position" => dir},
          "country_id" => CommerceFront.Settings.get_country_by_name(country_name) |> Map.get(:id)
        }
        |> IO.inspect()

      CommerceFront.Settings.register_without_products(params) |> IO.inspect()
      Process.sleep(2000)
    end

    # samples = [
    #   {"haho3000", "hh3100", 4, "left", "Koh Jia Xuan", "0", "0@gmail.com", ""}
    # ]

    # for {sponsor, username, rank_id, direction, fullname, phone, email, ic_no} = sample <- samples do
    #   params =
    #     %{
    #       "ic_no" => ic_no,
    #       "email" => email,
    #       "fullname" => fullname,
    #       "password" => username,
    #       "phone" => phone,
    #       "rank_id" => rank_id,
    #       "sponsor" => sponsor,
    #       "username" => username,
    #       "placement" => %{"position" => direction}
    #     }
    #     |> IO.inspect()

    #   CommerceFront.Settings.register_without_products(params)
    #   Process.sleep(2000)
    # end
  end

  def housekeeping() do
    samples1 = [
      "Indasan"
    ]

    users = Repo.all(from(u in Settings.User, where: u.username in ^samples1))

    user_ids = users |> Enum.map(& &1.id)

    Repo.delete_all(from(e in Settings.WalletTransaction, where: e.user_id in ^user_ids))

    Repo.delete_all(from(e in Settings.Ewallet, where: e.user_id in ^user_ids))

    Repo.delete_all(from(e in Settings.Referral, where: e.user_id in ^user_ids))

    Repo.delete_all(from(e in Settings.Placement, where: e.user_id in ^user_ids))

    Repo.delete_all(from(u in Settings.User, where: u.username in ^samples1))
  end

  def get_order() do
    pid = Process.whereis(:rest_1)
    Agent.get(pid, fn x -> x end)
  end

  def add_order() do
    pid = Process.whereis(:rest_1)

    Agent.update(pid, fn list -> List.insert_at(list, 0, %{items: [%{name: "apple", qty: 1}]}) end)
  end

  def write_json(bin, filename) do
    check = File.exists?(File.cwd!() <> "/media")

    path =
      if check do
        File.cwd!() <> "/media"
      else
        File.mkdir(File.cwd!() <> "/media")
        File.cwd!() <> "/media"
      end

    File.rm_rf("./priv/static/images/uploads")
    File.ln_s("#{File.cwd!()}/media/", "./priv/static/images/uploads")

    File.rm_rf("#{path}/#{filename}")
    File.touch("#{path}/#{filename}")

    IO.inspect("writing into... #{path} #{filename}")

    File.write("#{path}/#{filename}", bin)
  end

  def eval_codes(singular, plural) do
    struct =
      singular |> String.split("_") |> Enum.map(&(&1 |> String.capitalize())) |> Enum.join("")

    dynamic_code =
      """
        alias CommerceFront.Settings.#{struct}
        def list_#{plural}() do
          Repo.all(#{struct})
        end
        def get_#{singular}!(id) do
          Repo.get!(#{struct}, id)
        end
        def create_#{singular}(params \\\\ %{}) do
          #{struct}.changeset(%#{struct}{}, params) |> Repo.insert() |> IO.inspect()
        end
        def update_#{singular}(model, params) do
          #{struct}.changeset(model, params) |> Repo.update() |> IO.inspect()
        end
        def delete_#{singular}(%#{struct}{} = model) do
          Repo.delete(model)
        end

        random_id = makeid(4)
        #{singular}Source = new phoenixModel({
          columns: [
          
            { label: 'id', data: 'id' },
            { label: 'Action', data: 'id' }

          ],
          moduleName: "#{struct}",
          link: "#{struct}",
          customCols: customCols,
          buttons: [{
            buttonType: "grouped",
            name: "Manage",
            color: "outline-warning",
            buttonList: [

              {
                name: "Edit",
                iconName: "fa fa-edit",
                color: "btn-sm btn-outline-warning",
                onClickFunction: editData,
                fnParams: {
                  drawFn: enlargeModal,
                  customCols: customCols
                }
              },
              {
                name: "Delete",
                iconName: "fa fa-trash",
                color: "outline-danger",
                onClickFunction: deleteData,
                fnParams: {}
              }
            ],
            fnParams: {

            }
            }, ],
          tableSelector: "#" + random_id
        })
        #{singular}Source.load(random_id, "#tab1")



          function call#{struct}() {
            #{singular}Source2 = new phoenixModel({
              columns: [{
                  label: 'Name',
                  data: 'name'
                },
                {
                  label: 'Action',
                  data: 'id'
                }
              ],
              moduleName: "#{struct}",
              link: "#{struct}",
              buttons: [{
                name: "Select",
                iconName: "fa fa-check",
                color: "btn-sm btn-outline-success",
                onClickFunction: (params) => {
                  var dt = params.dataSource;
                  var table = dt.table;
                  var data = table.data()[params.index]
                  console.log(data.id)
                  $("input[name='Book[#{singular}][name]']").val(data.name)
                  $("input[name='Book[#{singular}][id]']").val(data.id)
                  $("input[name='Book[#{singular}_id]']").val(data.id)
                  $("#myModal").modal('hide')
                },
                fnParams: {
                 
                }
              }, ],
              tableSelector: "#" + random_id
            })
            App.modal({
              selector: "#myModal",
              autoClose: false,
              header: "Search #{struct}",
              content: `
              <div id="#{singular}">

              </div>`
            })
            #{singular}Source2.load(makeid(4), '##{singular}')
            #{singular}Source2.table.on("draw", function() {
              if ($("#search_user").length == 0) {
                $(".module_buttons").prepend(`
                  <label class="col-form-label " for="inputSmall">#{struct} </label>
                  <input class="mx-4 form-control form-control-sm" id="search_user"></input>
                            `)
              }
              $('input#search_user').on('change', function(e) {
                var query = $(this).val()
                #{singular}Source2.table
                  .columns(0)
                  .search(query)
                  .draw();
              })
            })
          }



      """
      |> IO.puts()
  end

  @doc """
  CommerceFront.eval_svt("stock_adjustment", "stock_adjustments", %{})
  """

  def eval_svt(
        singular,
        plural,
        opts
      ) do
    struct =
      singular |> String.split("_") |> Enum.map(&(&1 |> String.capitalize())) |> Enum.join("")

    relationship = opts |> Map.get(:relationship, :none)
    child_id = opts |> Map.get(:child_id)
    parent_module = opts |> Map.get(:parent_module)
    preloaded_parent = opts |> Map.get(:preloaded_parent)

    dynamic_code =
      case relationship do
        :many ->
          """
          /** @type {import('./$types').PageLoad} */

          import { genInputs, postData, buildQueryString } from '$lib/index.js';
          import { PHX_HTTP_PROTOCOL, PHX_ENDPOINT } from '$lib/constants';
          export const load = async ({ fetch, params, parent }) => {
          let url = PHX_HTTP_PROTOCOL + PHX_ENDPOINT ,module;

          let inputs = await genInputs(url, '#{struct}'), scope = "get_product_countries";

          const queryString = buildQueryString({ scope: scope, id: params["#{child_id}"] });
          const response = await fetch(url + '/svt_api/webhook?' + queryString, {
            headers: {
                  'Content-Type': 'application/json'
              }
          });
            if (response.ok) {
                let dataList = await response.json();
                return {
                    dataList: dataList,
                    #{child_id}: params['#{child_id}'],
                    module: '#{struct}',
                    inputs: inputs
                };
            }
          };



          // new lines 


          <script>
            import Datatable from '$lib/components/Datatable.svelte';
            /** @type {import('./$types').PageData} */
            export let data;
            let inputs = data.inputs,
              dataList = data.dataList;
          </script>

          <Datatable
            data={{
              showNew: true,
              canDelete: true,
              appendQueries: { #{child_id}: data.#{child_id} },
              inputs: inputs,
              search_queries: null,
              model: '#{struct}',
              preloads: ['product', 'country'],
              customCols: [
                {
                  title: 'General',
                  list: [
                    'id',
                    {
                      label: '#{parent_module}',
                      selection: '#{parent_module}',
                      multiSelection: true,
                      dataList: dataList.#{preloaded_parent},
                      module: '#{parent_module}',
                      parentId: data.#{child_id},
                      parent_module: '#{struct}'
                    }
                  ]
                }
              ],
              columns: [
                { label: 'ID', data: 'id' },
                { label: 'Product', data: 'name', through: ['product'] },
                { label: 'Country', data: 'name', through: ['country'] }
                // { label: 'URL', data: 'route', through: ['app_route'] }
              ]
            }}
          />





          """

        _ ->
          """
          /** @type {import('./$types').PageLoad} */

          import { genInputs, postData, buildQueryString } from '$lib/index.js';
          import { PHX_HTTP_PROTOCOL, PHX_ENDPOINT } from '$lib/constants';
          export const load = async () => {
          let url = PHX_HTTP_PROTOCOL + PHX_ENDPOINT ,module;

          let inputs = await genInputs(url, '#{struct}')
            return {module: '#{struct}',
              inputs: inputs
            };
          };

          // new lines 



          <script>
          import { PHX_HTTP_PROTOCOL, PHX_ENDPOINT } from '$lib/constants';
          import { goto } from '$app/navigation';
          import Datatable from '$lib/components/Datatable.svelte';
          import { buildQueryString, postData } from '$lib/index.js';
          /** @type {import('./$types').PageData} */
          export let data;

          let inputs = data.inputs;
          var url = PHX_HTTP_PROTOCOL + PHX_ENDPOINT;

          function downloadDO(data, checkPage, confirmModal) {
            window.open(url + '/pdf?type=do&id=' + data.id, '_blank').focus();
          }
          function viewDO(data, checkPage, confirmModal) {
            goto('/deliveries/' + data.id);
          }
          function showCondition(data) {
            var bool = false;
            if (data.status == 'processing') {
              bool = true;
            }
            return bool;
          }
          function showCondition2(data) {
            var bool = false;
            if (data.status == 'pending_delivery') {
              bool = true;
            }
            return bool;
          }
          function doMarkPendingDelivery(data, checkPage, confirmModal) {
            console.log(data);
            console.log('transfer approved!');

            confirmModal(true, 'Are you sure to mark this order as pending delivery?', () => {
              postData(
                { scope: 'mark_do', id: data.id, status: 'pending_delivery' },
                {
                  endpoint: url + '/svt_api/webhook',
                  successCallback: () => {
                    checkPage();
                  }
                }
              );
            });
          }
          function doMarkSent(data, checkPage, confirmModal) {
            console.log(data);
            console.log('transfer approved!');

            confirmModal(
              true,
              `
              <label class="my-4 text-sm font-medium block 
              text-gray-900 dark:text-gray-300 space-y-2">
              <span>Shipping Ref</span>  <input name="shipping_ref" 
              placeholder="" type="text" class="block w-75 disabled:cursor-not-allowed disabled:opacity-50 p-2.5 focus:border-primary-500 focus:ring-primary-500 dark:focus:border-primary-500 dark:focus:ring-primary-500 bg-gray-50 text-gray-900 dark:bg-gray-600 dark:text-white dark:placeholder-gray-400 border-gray-300 dark:border-gray-500 text-sm rounded-lg"> </label>
              <span class="">Are you sure to mark this order as sent?</span>`,
              () => {
                var dom = document.querySelector("input[name='shipping_ref']");
                postData(
                  { scope: 'mark_do', shipping_ref: dom.value, id: data.id, status: 'sent' },
                  {
                    endpoint: url + '/svt_api/webhook',
                    successCallback: () => {
                      checkPage();
                    }
                  }
                );
              }
            );
          }
          </script>

          <Datatable
          data={{
            inputs: inputs,
            join_statements: JSON.stringify([

              { user: 'user' }
            ]),
            search_queries: ['a.id|b.username|b.fullname'],
            model: 'Sale',
            preloads: ['user', 'sales_person', 'payment'],
            buttons: [
              { name: 'Preview', onclickFn: viewDO },
              { name: 'Download DO (PDF)', onclickFn: downloadDO },
              {
                name: 'Mark Pending Delivery',
                onclickFn: doMarkPendingDelivery,
                showCondition: showCondition
              },
              { name: 'Mark Sent', onclickFn: doMarkSent, showCondition: showCondition2 }
            ],
            customCols: [
              {
                title: 'Order',
                list: [
                  'id',
                  'shipping_method',
                  'shipping_company',
                  'shipping_ref',
                  { label: 'remarks', editor2: true },
                  {
                    label: 'role_id',
                    selection: 'Role',
                    module: 'Role',
                    customCols: null,
                    search_queries: ['a.name'],
                    newData: 'name',
                    title_key: 'name'
                  },
                ]
              }
            ],
            columns: [
              { label: 'ID', data: 'id' },
              { label: 'Timestamp', data: 'inserted_at', formatDateTime: true , offset: 8},

              {
                label: 'Status',
                data: 'status',
                isBadge: true,
                color: [
                  {
                    key: 'pending_payment',
                    value: 'yellow'
                  },
                  {
                    key: 'pending_confirmation',
                    value: 'yellow'
                  },
                  {
                    key: 'processing',
                    value: 'blue'
                  },
                  {
                    key: 'sent',
                    value: 'pink'
                  },
                  {
                    key: 'pending_delivery',
                    value: 'purple'
                  },
                  {
                    key: 'complete',
                    value: 'green'
                  }
                ]
              },
              { label: 'User', data: 'username', through: ['user'] },
              { label: 'Sales Person', data: 'username', through: ['sales_person'] }
            ]
          }}
          />


          """
      end
      |> IO.puts()
  end

  def upload_file(params) do
    check_upload =
      Map.values(params)
      |> Enum.with_index()
      |> Enum.filter(fn x -> is_map(elem(x, 0)) end)
      |> Enum.filter(fn x -> :__struct__ in Map.keys(elem(x, 0)) end)
      |> Enum.filter(fn x -> elem(x, 0).__struct__ == Plug.Upload end)

    # Enum.reduce([1, 2, 3], 0, fn x, acc -> x + acc end)

    if check_upload != [] do
      upload_fn = fn check_upload_item, xparams ->
        file_plug = check_upload_item |> elem(0)
        index = check_upload_item |> elem(1)

        check = File.exists?(File.cwd!() <> "/media")

        path =
          if check do
            File.cwd!() <> "/media"
          else
            File.mkdir(File.cwd!() <> "/media")
            File.cwd!() <> "/media"
          end

        final =
          if is_map(file_plug) do
            IO.inspect(is_map(file_plug))
            fl = String.replace(file_plug.filename, "'", "")
            File.cp(file_plug.path, path <> "/#{fl}")
            "/images/uploads/#{fl}"
          else
            "/images/uploads/#{file_plug}"
          end

        Map.put(xparams, Enum.at(Map.keys(xparams), index), final)
      end

      Enum.reduce(check_upload, params, fn x, acc -> upload_fn.(x, acc) end)

      # for check_upload_item <- check_upload do
      # end
    else
      params
    end
  end

  def translation() do
    lines = File.read!("translation.csv") |> String.split("\n") |> Enum.reject(&(&1 == ""))
    {header, lines} = List.pop_at(lines, 0)
    header = String.split(header, ",")

    for item <- lines do
      items = String.split(item, ",")

      Enum.zip(header, items) |> Enum.into(%{})
    end
  end
end
