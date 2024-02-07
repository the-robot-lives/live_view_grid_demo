defmodule NoizuGridWeb.GridLive do
  use NoizuGridWeb, :live_view

  @empty_grid %NoizuGrid{}

  #  def grid_update(identifier, grid, socket) do
  #    # Save Updated Grid for User/Session
  #    :persistent_term.put({:grid, identifier}, grid)
  #    {:ok, socket}
  #  end

  def grid(:fetch, socket, grid) when is_struct(grid) do
    grid(:fetch, socket, grid.identifier)
  end
  def grid(:fetch, socket, grid) when is_bitstring(grid) do
    fetch = with [latest|_] <- :persistent_term.get({:grid_changes, grid}, []) do
      latest
    else
      _ ->
        :persistent_term.get({:grid, grid}, %NoizuGrid{@empty_grid| identifier: grid})
    end
    {:ok, {socket, fetch}}
  end

  def grid(:update, socket, grid) when is_struct(grid) do
    # @todo use dets or ets
    :persistent_term.put({:grid, grid.identifier}, grid)
    h = :persistent_term.get({:grid_changes, grid.identifier}, [])
    :persistent_term.put({:grid_changes, grid.identifier}, [grid|h])
    :persistent_term.put({:grid_redo, grid.identifier}, [])
    {:ok, {socket, grid}}
  end

  def grid(:save, socket, grid) when is_struct(grid) do
    # @todo use dets or ets
    :persistent_term.put({:grid, grid.identifier}, grid)
    :persistent_term.put({:grid_changes, grid.identifier}, [])
    :persistent_term.put({:grid_redo, grid.identifier}, [])
    socket = push_navigate(socket, to: "/dash/#{grid.identifier}")
    {:ok, {socket, grid}}
  end

  def grid(:undo, socket, grid) when is_struct(grid) do
    fetch = with [latest| [previous|t]] <- :persistent_term.get({:grid_changes, grid.identifier}, []) do
      r = :persistent_term.get({:grid_redo, grid.identifier}, [])
      :persistent_term.put({:grid_redo, grid.identifier}, [latest|r])
      :persistent_term.put({:grid_changes, grid.identifier}, [previous|t])
      previous
    else
      _ ->
        grid
    end
    {:ok, {socket, fetch}}
  end

  def grid(:redo, socket, grid) when is_struct(grid) do
    fetch = with [redo|t] <- :persistent_term.get({:grid_redo, grid.identifier}, []) do
      r = :persistent_term.get({:grid_changes, grid.identifier}, [])
      :persistent_term.put({:grid_changes, grid.identifier}, [redo|r])
      :persistent_term.put({:grid_redo, grid.identifier}, t)
      redo
    else
      _ ->
        grid
    end
    {:ok, {socket, fetch}}
  end

  def grid(:new, socket, grid) do
    socket = push_navigate(socket, to: "/dash/new")
    {:ok, {socket, grid}}
  end

  def grid_identifier(params, session, socket) do
    with %{grid_identifier: x} <- socket.assigns do
      {:ok, x}
    else
      _ ->
        with %{"session" => "grid:" <> session} <- params,
             uuid <- UUID.string_to_binary!(session),
             slug <- UUID.binary_to_string!(uuid, :slug) do
          {:ok, "grid:" <> slug}
        else
          _ ->
            slug = UUID.uuid5(:oid, "noizu.com/#{session["_csrf_token"]}/#{:os.system_time(:millisecond)}", :slug)
            {:ok, "grid:" <> slug}
        end
    end
  rescue _ ->
    slug = UUID.uuid5(:oid, "noizu.com/#{session["_csrf_token"]}/#{:os.system_time(:millisecond)}", :slug)
    {:ok, "grid:" <> slug}
  end

  def mount(params, session, socket) do
    {:ok, gid} = grid_identifier(params, session, socket)
    socket = socket
             |> assign(:grid_identifier, gid)
    {:ok, socket}
  end

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

  def render(assigns) do
    ~H"""
    <div class="bg-white py-4 h-full ">
    <div class="mx-auto max-w-7xl px-6 lg:px-8">
    <div class="mx-auto max-w-2xl sm:text-center">
      <p class="mt-2 text-3xl font-bold tracking-tight text-gray-900 sm:text-4xl">User Configurable LiveView Dashboard Demo</p>
      <p class="mt-6 text-lg leading-8 text-gray-600">Lorem ipsum, dolor sit amet consectetur adipisicing elit. Maiores impedit perferendis suscipit eaque, iste dolor cupiditate blanditiis.</p>
    </div>
    </div>
    <div class="h-full w-full pt-0">
    <article class="block p-2 pt-0  w-full  h-full   ">

    <div class="mx-4 mb-8 mt-0">
    <!-- Title -->
    <h2 class="
      text-4xl font-extrabold leading-none
      tracking-tight text-gray-900
      md:text-5xl lg:text-6xl">
    LiveGrid
    </h2>
    <!-- Subtitle -->
    <p class="text-lg text-gray-500 lg:text-xl">
    User Configurable Dashboard/LiveView Grid
    </p>

    <!-- SubSubtitle -->
    <p class="text-md text-gray-400 lg:text-lg">
    Dashboard: <%= @grid_identifier %>
    </p>    <p>By <a class="underline hover:uppercase" href="https://noizu.com">Noizu Labs</a> See the <a class="underline text-blue-900 hover:uppercase" href="https://therobotlives.com/">Blog.</a></p>
    </div>

    <.debug_details grid={assigns[:grid] || nil} grid_callback={{__MODULE__, :grid, []}}/>


    <div class="flex flex-row w-full h-full">
    <div class="w-1/6 h-full p-4">

    <div class="w-full h-full flex flex-col space-y-4">
      <div
        id="dash-component-alpha"
        class="border border-black text-center"
        draggable="true"
        phx-hook="GridOption"
        phx-value-widget={NoizuGridWeb.Widget.AlphaWidget}
        phx-value-settings="{}"
        phx-value-cols="3"
        phx-value-rows="2"
      >
        Alpha Widget
      </div>
    </div>

    </div>
    <div class="w-5/6 border-2 h-full p-4">
    <%=
    live_render(
        @socket,
        NoizuGrid,
        id: "#{@grid_identifier}-grid",
        layout: false,
        container: {:div, [class: "w-full h-full"]},
        session: %{
          "demo" => true,
          "grid" => @grid_identifier,
          "callback" => {__MODULE__, :grid, []}
        }
    )
    %>
    </div>

    </div>

    </article>
    </div>
    </div>
    """
  end

end
