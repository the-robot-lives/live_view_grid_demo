defmodule Noizu.LiveGrid.Cell do
  use Phoenix.LiveComponent


  defstruct [
    identifier: nil,
    contents: []
  ]

#
#  attr :cell, :string, required: true
#  attr :action, :string, required: true
#  attr :position, :string, required: true, values: ["top", "bottom", "left", "right"]
#  def action_bar(assigns) do
#    ~H"""
#    <div class={["action-bar", @position, @position in ["top","bottom"] && "horizontal" || "vertical"]}>
#      <div class="hot-zone">
#        <div class="bar"/>
#        <div class="action"  >
#          <span phx-click="expand:cell" phx-value-cell={@cell} phx-value-at={@position} class="hero-arrows-pointing-out"/>
#          <span phx-click={@action} phx-value-cell={@cell} phx-value-at={@position} class="hero-plus-circle"/>
#          <span phx-click="shrink:cell" phx-value-cell={@cell} phx-value-at={@position} class="hero-arrows-pointing-in"/>
#        </div>
#        <div class="bar"/>
#      </div>
#    </div>
#    """
#  end
#
#
#
#  def grid_element_size(_) do
#    "w-full h-full"
#  end
#
#            <div
#  id={"#{@id}-cell"}
#  class={["live-cell", grid_element_size(@contents)]}
#  phx-hook="GridCell"
#  phx-value-menu={"#{@grid}-contextmenu"}
#  phx-value-grid={@grid}
#  draggable={@contents[:contents] && "true" || "false"}
#  phx-value-contents={@contents[:contents][:identifier]}
#  >

  def render(assigns) do
    ~H"""
    <div
     id={"#{@id}-cell"}
     class={["live-cell"]}
    >
    [CELL]
    </div>
    """
  end
end