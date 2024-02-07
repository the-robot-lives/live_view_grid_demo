defmodule NoizuGrid.CellBody do
 defstruct [
  identifier: nil,
  session: %{},
  module: nil,
  live_view?: false
 ]
end

defmodule NoizuGrid.Cell do
  use Phoenix.LiveComponent
  defstruct [
    identifier: nil,
    component: nil,
    settings: nil,
    layout: nil,
    body: []
  ]

  attr :cell, :string, required: true
  attr :action, :string, required: true
  attr :position, :string, required: true, values: ["top", "bottom", "left", "right"]
  def action_bar(assigns) do
    ~H"""
    <div class={["action-bar", @position, @position in ["top","bottom"] && "horizontal" || "vertical"]}>
      <div class="hot-zone">
        <div class="bar"/>
        <div class="action"  >

          <span phx-click={@action} phx-value-cell={@cell} phx-value-at={@position} class="hero-plus-circle"/>

        </div>
        <div class="bar"/>
      </div>
    </div>
    """
  end

  def layout(%{col: col, row: row, width: width, height: height}) do

    "col-start-#{col} row-start-#{row} col-span-#{width} row-span-#{height}"
  end

  def render(assigns) do
    ~H"""
    <div
     id={"#{@id}-cell"}
     class={["live-cell", layout(@cell.layout)]}
    >

    <%= case @cell.component.__live__().kind do %>
      <% :view -> %>
       <%=
          live_render(
              @socket,
              @cell.component,
              id: "#{@cell.identifier}",
              container: {:div, [class: "w-full h-full z-40"]},
              session: @cell.settings,
              layout: false
           )
          %>
      <% :component -> %>
         <.live_component
                id={"#{@cell.identifier}"}
                module={@cell.component}
                session={@cell.settings}
            />
    <% end %>
    </div>
    """
  end


  def render2(assigns) do
    ~H"""

    <div
     id={"#{@id}-cell"}
     class="live-cell col-span-1 row-span-1"
    >


    <.action_bar position="top" action="inject:cell" cell={@id} />
    <.action_bar position="bottom" action="inject:cell" cell={@id} />
    <.action_bar position="left" action="inject:cell" cell={@id} />
    <.action_bar position="right" action="inject:cell" cell={@id} />


          <%= case @contents.body do %>
            <% %{live_view?: true} -> %>
          <%=
          live_render(
              @socket,
              @contents.body.module,
              id: "#{@contents.body.identifier}",
              container: {:div, [class: "w-full h-full"]},
              session: @contents.body.session,
              layout: false
           )
          %>
            <% %{live_view?: false} -> %>
             <.live_component
                id={"#{@contents.body.identifier}"}
                module={@contents.body.module}
                session={@contents.body.session}
            />
            <% _ -> %>
            <div class="min-w-32 min-h-32 w-[100%] h-[100%] flex flex-col items-center justify-center empty-cell"><div>[PLACEHOLDER]</div></div>
          <% end %>
    </div>
    """
  end
end
