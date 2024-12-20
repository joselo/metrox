defmodule AppWeb.TabManager do
  @moduledoc false

  import AppWeb.TabsConfig, only: [view_groups: 0, tabs_config: 0]
  import Phoenix.Component, only: [assign_new: 3, assign: 2]
  import Phoenix.LiveView, only: [attach_hook: 4]

  def on_mount(:default, _params, _session, socket) do
    new_socket =
      socket
      |> assign_new(:tabs, fn -> tabs_config() end)
      |> attach_hook(:active_tab, :handle_params, &set_active_tab/3)

    {:cont, new_socket}
  end

  defp set_active_tab(_params, _url, socket) do
    active_tab = get_active_tab(socket.view)
    {:cont, assign(socket, active_tab: active_tab)}
  end

  defp get_active_tab(view) do
    view_groups()
    |> Enum.find(fn {_tab, views} -> view in views end)
    |> case do
      {tab, _} -> tab
      nil -> nil
    end
  end
end
