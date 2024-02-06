defmodule NoizuGridWeb.Widget.AlphaWidget do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
        <div> Alpha WIDGET - <%= DateTime.to_unix(@mounted) %> </div>
    """
  end

  def mount(_,_, socket) do
    socket = assign(socket, :mounted, DateTime.utc_now())
    {:ok, socket}
  end
end
