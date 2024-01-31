defmodule Noizu.LiveGrid do
  use Phoenix.LiveView

  defstruct [
    identifier: nil,
    contents: []
  ]

  def debug_details(assigns) do
    ~H"""
    <container>
      <h3 class="mb-2 text-lg text-gray-500 lg:text-xl">Raw Data</h3>
      <div class="prose min-w-full">
        <pre class="w-full"><code class="elixir-code"><%=
          "#{inspect @grid, limit: :infinity, width: 20, pretty: true}"
        %></code></pre>
      </div>

      <h3 class="mt-8 mb-2 text-lg text-gray-500 lg:text-xl">Call Backs</h3>
      <div class="prose min-w-full">
        <pre class="w-full"><code class="elixir-code"><%=
          "#{inspect @grid_callback, limit: :infinity, width: 120, pretty: true}"
        %></code></pre>
      </div>


      <h3 class="mt-8 mb-2 text-lg text-gray-500 lg:text-xl">Tool Bar</h3>

      <div class="grid grid-cols-3 border p-2 mb-16 bg-slate-100 ">
        <div class="flex justify-center">
          <button
            phx-click="grid:new"
            class="bg-slate-400 rounded py-2 px-4 flex items-center justify-center">
            <span class="hero-plus-circle flex items-center justify-center"/>
            New
          </button>
        </div>
        <div class="flex justify-center">
          <button
            phx-click="grid:save"
            class="bg-slate-400 rounded py-2 px-4 flex items-center justify-center">
            <span class="hero-plus-circle flex items-center justify-center"/>
            Save
          </button>
        </div>
        <div class="flex justify-center">
          <button
            phx-click="grid:undo"
            class="bg-slate-400 rounded py-2 px-4 mr-2 flex items-center justify-center">
            <span class="hero-plus-circle flex items-center justify-center"/>
            Undo
          </button>
          <button
            phx-click="grid:redo"
            class="bg-slate-400 rounded py-2 px-4 flex items-center justify-center">
            <span class="hero-plus-circle flex items-center justify-center"/>
            Redo
          </button>
        </div>
      </div>
      </container>
    """
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

  def render(assigns) do
    ~H"""
    <div class="live-grid flex flex-col h-[90vh] w-full ">
    <.debug_details :if={@demo}  grid={@grid} grid_callback={@grid_callback}/>

      <div class="underlay"></div>
      <div class="grid grid-cols-4 w-full h-full border">
        <.live_component
          :if={@grid.contents == []}
          id={"#{@id}."}
          grid={@grid.identifier}
          module={Noizu.LiveGrid.Cell} contents={%Noizu.LiveGrid.Cell{}} />
        <.live_component
            :for={{child,index} <- Enum.with_index(@grid.contents)}
            id={"#{@id}.#{index}"}
            grid={@grid.identifier}
            module={child.__struct__}
            contents={child}
        />
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
             |> assign(:id, params["id"])
             |> assign(:demo, params["demo"] || false)
    {:ok, socket}
  end

  def handle_event("grid:save",_,socket) do
    {m,f,a} = socket.assigns.grid_callback
    {:ok, {socket, grid}} = apply(m,f,[:save, socket, socket.assigns.grid])
    socket = socket
             |> assign(:grid, grid)
    {:noreply, socket}
  end

  def handle_event("grid:new",_,socket) do
    {m,f,a} = socket.assigns.grid_callback
    {:ok, {socket, grid}} = apply(m,f,[:new, socket, socket.assigns.grid])
    socket = socket
             |> assign(:grid, grid)
    {:noreply, socket}
  end


end