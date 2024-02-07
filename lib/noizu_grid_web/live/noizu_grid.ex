defmodule NoizuGrid do
  use Phoenix.LiveView
  require Record
  require NoizuGrid.Cell


  defstruct [
    identifier: nil,
    contents: [],
    rows: 12,
    cols: 12,
    cell_map: %{}
  ]

  def refresh(grid) do
    cell_map = Enum.reduce(grid.contents, %{},
      fn(cell,acc) ->
        Enum.reduce(cell.layout.row..(cell.layout.row + cell.layout.height - 1),acc, fn(y,acc) ->
          Enum.reduce(cell.layout.col..(cell.layout.col + cell.layout.width - 1),acc, fn(x,acc) ->
            Map.put(acc, {x,y}, true)
          end)
        end)
      end)
    %NoizuGrid{grid | cell_map: cell_map}
  end


  def context_menu(assigns) do
  ~H"""
    <div id={"#{@for}-contextmenu"} class="hidden absolute z-10">
      <form
        phx-submit="context-menu"
        action="POST"
        class="bg-white p-2 border-2 border-gray-800 flex flex-col justify-leading space-y-2">
        <input type="hidden" name="menu" value={"##{@for}-contextmenu"}/>
        <input type="hidden" name="target"/>
        <button type="submit" class="rounded-sm border-2 bg-white text-left" name="action" value="split-h">Split Horizontal</button>
        <button type="submit" class="rounded-sm border-2 bg-white text-left" name="action" value="split-v">Split Vertical</button>
        <button type="submit" class="rounded-sm border-2 bg-white text-left" name="action" value="remove">Remove Cell</button>
      </form>
    </div>
  """
  end

  @doc """
  Render hint to insure tailwind grid is populated.
  """
  def grid_hint(assigns) do
  ~H"""
    <div class=" resize hover:resize
      grid-cols-1 grid-rows-1
      grid-cols-2 grid-rows-2
      grid-cols-3 grid-rows-3
      grid-cols-4 grid-rows-4
      grid-cols-5 grid-rows-5
      grid-cols-6 grid-rows-6
      grid-cols-7 grid-rows-7
      grid-cols-8 grid-rows-8
      grid-cols-9 grid-rows-9
      grid-cols-10 grid-rows-10
      grid-cols-11 grid-rows-11
      grid-cols-12 grid-rows-12
      bg-red-200
    ">
    <div class="
      col-start-1 col-start-2 col-start-3 col-start-4 col-start-5 col-start-6 col-start-7 col-start-8 col-start-9 col-start-10 col-start-11 col-start-12
      row-start-1 row-start-2 row-start-3 row-start-4 row-start-5 row-start-6 row-start-7 row-start-8 row-start-9 row-start-10 row-start-11 row-start-12

      col-span-1 col-span-2 col-span-3 col-span-4 col-span-5 col-span-6 col-span-7 col-span-8 col-span-9 col-span-10 col-span-11 col-span-12
      row-span-1 row-span-2 row-span-3 row-span-4 row-span-5 row-span-6 row-span-7 row-span-8 row-span-9 row-span-10 row-span-11 row-span-12

      hover:col-span-1 hover:col-span-2 hover:col-span-3 hover:col-span-4 hover:col-span-5 hover:col-span-6 hover:col-span-7 hover:col-span-8 hover:col-span-9 hover:col-span-10 hover:col-span-11 hover:col-span-12
      hover:row-span-1 hover:row-span-2 hover:row-span-3 hover:row-span-4 hover:row-span-5 hover:row-span-6 hover:row-span-7 hover:row-span-8 hover:row-span-9 hover:row-span-10 hover:row-span-11 hover:row-span-12

    "></div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
    <div
      id={@id <> "-grid"}
      phx-hook="NoizuGrid"
      phx-value-cols={@grid.cols}
      phx-value-rows={@grid.rows}
      class="noizu-grid"
    >
      <div class="underlay"></div>
      <div
        class={"noizu-grid-grid grid grid-cols-#{@grid.cols} grid-rows-#{@grid.rows}"}
      >





      <!-- Second loop through grid representation, output entry for any empty cell -->
      <%= for row  <- 1 .. @grid.rows do %>
        <%= for col  <- 1 .. @grid.cols do %>
          <%# unless @grid.cell_map[{col, row}] do %>
            <div
              cell-col={col}
              cell-row={row}
              cell-populated={@grid.cell_map[{col, row}] && "true" || "false"}
              class={["grid-cell empty col-start-#{col} row-start-#{row}"]}>&nbsp;</div>
          <%# end %>
        <% end %>
      <% end %>

      <!-- First Render known elements -->
      <%= for {cell,idx} <- Enum.with_index(@grid.contents) do %>
        <.live_component
          id={"#{@id}-#{idx}"}
          index={idx}
          grid={@id}
          module={cell.__struct__}
          cell={cell}
        />
      <% end %>
      </div>

      <.context_menu for={@id}/>
    </div>
    """
  end


  def mount(_, params, socket) do
    {m,f,a} = params["callback"]
    {:ok, {socket, grid}} = apply(m,f,[:fetch, socket, params["grid"] |a])
    socket = socket
             |> assign(:grid_callback, params["callback"])
             |> assign(:grid, grid)
             |> assign(:id, socket.id)
             |> assign(:demo, params["demo"] || false)
    {:ok, socket}
  end

  def handle_event("cell:add", params = %{"widget" => widget, "position" => %{"col" => col, "row" => row}, "clip" => %{"cols" => width, "rows" => height}}, socket) do
    widget = String.to_existing_atom(widget)
    IO.inspect(params, label: "CELL:ADD - #{inspect widget}", pretty: true)

    identifier = params["identifier"] || "widget-#{:os.system_time(:millisecond)}"

    inject = %NoizuGrid.Cell{
      identifier: identifier,
      layout: %{col: col, row: row, width: width, height: height},
      component: widget,
      settings: Jason.decode!(params["settings"])
    }
    grid = update_in(socket.assigns.grid, [Access.key(:contents)], & &1 ++ [inject])
           |> refresh()

    {m,f,a} = socket.assigns.grid_callback
    {:ok, {socket, grid}} = apply(m,f,[:update, socket, grid])
    socket = socket
             |> assign(:grid, grid)

    {:noreply, socket}
  end

  def handle_event("grid:save",_,socket) do
    {m,f,a} = socket.assigns.grid_callback
    {:ok, {socket, grid}} = apply(m,f,[:save, socket, socket.assigns.grid])
    grid = refresh(grid)
    socket = socket
             |> assign(:grid, grid)
    {:noreply, socket}
  end

  def handle_event("grid:new",_,socket) do
    {m,f,a} = socket.assigns.grid_callback
    {:ok, {socket, grid}} = apply(m,f,[:new, socket, socket.assigns.grid])
    grid = refresh(grid)
    socket = socket
             |> assign(:grid, grid)
    {:noreply, socket}
  end


end
