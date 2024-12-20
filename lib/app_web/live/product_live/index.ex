defmodule AppWeb.ProductLive.Index do
  use AppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <div>
        Products index
      </div>

      <div>
        <.link navigate={~p"/products/show"} class="dark:text-white font-semibold hover:underline">
          {gettext("Show Product")}
        </.link>
      </div>
    </div>
    """
  end
end
