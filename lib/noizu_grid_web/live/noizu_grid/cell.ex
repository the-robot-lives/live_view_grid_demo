defmodule Noizu.LiveGrid.CellBody do
 defstruct [
  identifier: nil,
  session: %{},
  module: nil,
  live_view?: false
 ]
end

defmodule Noizu.LiveGrid.Cell do
  use Phoenix.LiveComponent

  defstruct [
    body: []
  ]

  def render(assigns) do
    ~H"""
    <div
     id={"#{@id}-cell"}
     class="live-cell w-full h-full"
    >



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
            <div class="h-full">[PLACEHOLDER]</div>
          <% end %>
    </div>
    """
  end
end