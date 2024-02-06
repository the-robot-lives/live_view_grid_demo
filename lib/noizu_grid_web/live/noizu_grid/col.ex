defmodule NoizuGrid.Col do
  use Phoenix.LiveComponent

  defstruct [
    contents: []
  ]

  def render(assigns) do
    ~H"""
    <div
     id={"#{@id}-col"}
     class={["live-col"]}
    >
        <div class="grid grid-cols-12">
        <.live_component
          :if={@contents.contents == []}
          id={"#{@id}."}
          grid={@grid}
          module={NoizuGrid.Cell} contents={%NoizuGrid.Cell{}} />
        <.live_component
            :for={{child,index} <- Enum.with_index(@contents.contents)}
            id={"#{@id}.#{index}"}
            grid={@grid}
            module={child.__struct__}
            contents={child}
        />
      </div>
    </div>
    """
  end
end
