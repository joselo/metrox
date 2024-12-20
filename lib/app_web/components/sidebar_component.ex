defmodule AppWeb.SidebarComponent do
  @moduledoc false

  use Phoenix.Component
  use Gettext, backend: AppWeb.Gettext
  use AppWeb, :verified_routes

  import AppWeb.CoreComponents, only: [icon: 1]

  alias Phoenix.LiveView.JS

  attr :id, :string, default: "sidebar"
  attr :tabs, :list, required: true
  attr :active_tab, :atom, required: true

  def sidebar(assigns) do
    ~H"""
    <header class="flex p-4 lg:hidden">
      <.link class="mr-4" phx-click={show_sidebar(@id)}>
        <.icon name="hero-bars-3" class="w-6 h-6" />
      </.link>

      <.sidebar_logo />
    </header>

    <div
      id={"#{@id}-bg"}
      class="fixed inset-0 bg-black/20 backdrop-blur transition-opacity hidden z-10"
      aria-hidden="true"
      phx-click={hide_sidebar(@id)}
    />

    <div
      id={"#{@id}-container"}
      class="fixed inset-y-0 left-0 w-60 max-lg:hidden bg-white dark:bg-zinc-800 dark:text-zinc-400 z-10 box-border"
    >
      <.close_button id={@id} />

      <div class="flex h-full min-h-0 flex-col">
        <aside id={@id} class="flex flex-1 flex-col overflow-y-auto">
          <.sidebar_nav active_tab={@active_tab} tabs={@tabs} />
        </aside>
      </div>
    </div>
    """
  end

  attr :id, :string, required: true

  defp close_button(assigns) do
    ~H"""
    <div class="absolute top-2 right-5 lg:hidden">
      <button
        id={"close-sidebar-btn-" <> @id}
        phx-click={hide_sidebar(@id)}
        type="button"
        class="mt-2 flex-none opacity-20 hover:opacity-40"
        aria-label={gettext("Cerrar")}
      >
        <.icon name="hero-x-mark-solid" class="w-6 h-6" />
      </button>
    </div>
    """
  end

  attr :tabs, :list, required: true
  attr :active_tab, :atom, required: true

  defp sidebar_nav(assigns) do
    ~H"""
    <div class="p-2">
      <div class="p-2">
        <.sidebar_logo />
      </div>

      <.sidebar_menu_item :for={item <- @tabs} active_tab={@active_tab} item={item} />
    </div>
    """
  end

  attr :item, :map, required: true
  attr :active_tab, :atom, default: nil

  defp sidebar_menu_item(assigns) do
    assigns =
      assigns
      |> assign_new(:toggle, fn -> has_tabs?(assigns.item) end)
      |> assign_new(:show_group, fn -> should_show_group?(assigns.item, assigns.active_tab) end)

    ~H"""
    <.sidebar_link item={@item} active_tab={@active_tab} toggle={@toggle} />

    <.sidebar_group :if={@toggle} tab={@item.tab} show_group={@show_group}>
      <.sidebar_menu_item :for={item <- @item.tabs} item={item} active_tab={@active_tab} />
    </.sidebar_group>

    <div :if={@item[:separator]} class="py-2">
      <div class="border-b dark:border-zinc-700"></div>
    </div>
    """
  end

  attr :item, :map, required: true
  attr :active_tab, :atom, default: nil
  attr :toggle, :boolean, required: true

  defp sidebar_link(assigns) do
    assigns =
      assigns
      |> assign_new(:active, fn -> active_tab?(assigns.item, assigns.active_tab) end)
      |> assign_new(:toggle_options, fn -> build_toggle_options(assigns.toggle, assigns.item) end)
      |> assign_new(:rest, fn -> assigns.item[:options] || [] end)

    ~H"""
    <div class={[
      "flex tabs-center rounded hover:bg-zinc-50 parent dark:hover:bg-zinc-700 my-1",
      @active && "bg-zinc-100 dark:bg-zinc-700 dark:text-white"
    ]}>
      <.link class="w-full p-2 flex whitespace-nowrap space-x-2" {@toggle_options} {@rest}>
        <.icon :if={@item[:icon]} name={@item.icon} class="h-6 w-6" />
        <div class="flex-1">{@item.label}</div>
        <div
          :if={@item[:badge]}
          class="justify-end text-center rounded border min-w-6 px-2 dark:border-zinc-600"
        >
          {@item[:badge]}
        </div>
        <div :if={@toggle} class="justify-end text-center min-w-6">
          <.icon name="hero-chevron-down" class="h-4 w-4" />
        </div>
      </.link>
    </div>
    """
  end

  attr :show_group, :boolean, required: true
  attr :tab, :atom, required: true
  slot :inner_block

  defp sidebar_group(assigns) do
    ~H"""
    <ul id={"sidebar-parent-#{@tab}"} class={["ml-11", !@show_group && "hidden"]}>
      {render_slot(@inner_block)}
    </ul>
    """
  end

  defp sidebar_logo(assigns) do
    ~H"""
    <.link navigate={~p"/"} class="flex text-lg font-semibold">
      <.icon name="hero-cube-transparent" class="w-6 h-6 mr-2 text-primary-600" /> METROEXODUS
    </.link>
    """
  end

  defp show_sidebar(id) when is_binary(id) do
    %JS{}
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> JS.show(
      to: "##{id}-container",
      transition:
        {"transition-all transform ease-out duration-100", "-translate-x-72", "translate-x-0"}
    )
    |> JS.add_class("overflow-hidden", to: "body")
  end

  defp hide_sidebar(id) when is_binary(id) do
    %JS{}
    |> JS.hide(
      to: "##{id}-container",
      transition:
        {"transition-all transform ease-out duration-100", "translate-x-0", "-translate-x-72"}
    )
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  defp toggle_group(tab) do
    JS.toggle(%JS{}, to: "#sidebar-parent-#{tab}")
  end

  defp has_tabs?(item) do
    item[:tabs] && !Enum.empty?(item.tabs)
  end

  defp should_show_group?(item, active_tab) do
    tabs = item[:tabs] || []

    tabs
    |> Enum.map(&Map.put(&1, :parent, item[:tab]))
    |> Enum.any?(fn %{parent: parent, tab: tab} ->
      parent == active_tab || tab == active_tab
    end)
  end

  defp active_tab?(item, active_tab) do
    item[:tab] && active_tab && item.tab == active_tab
  end

  defp build_toggle_options(toggle, item) do
    if toggle, do: ["phx-click": toggle_group(item.tab)], else: []
  end
end
