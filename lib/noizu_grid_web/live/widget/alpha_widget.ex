defmodule NoizuGridWeb.Widget.AlphaWidget do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
        <div class="border p-1 shadow-sm opacity-90 z-40 bg-blue-300"> Alpha WIDGET - <%= DateTime.to_unix(@mounted) %> </div>
    """
  end

  def mount(_,_, socket) do
    socket = assign(socket, :mounted, DateTime.utc_now())
    {:ok, socket}
  end
end
