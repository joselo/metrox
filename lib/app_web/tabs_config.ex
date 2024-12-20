defmodule AppWeb.TabsConfig do
  @moduledoc false

  use AppWeb, :verified_routes
  use Gettext, backend: AppWeb.Gettext

  def view_groups do
    %{
      home: [AppWeb.DashboardLive],
      products: [AppWeb.ProductLive.Index, AppWeb.ProductLive.Show],
      stock: [AppWeb.StockLive],
      clients: [AppWeb.ClientLive],
      account: [AppWeb.AccountLive],
      notifications: [AppWeb.NotificationLive]
    }
  end

  def tabs_config do
    [
      %{label: gettext("Dashboard"), icon: "hero-home-solid", tab: :home, options: [navigate: ~p"/"]},
      %{
        label: gettext("Inventory"),
        icon: "hero-inbox-stack-solid",
        tab: :inventory,
        tabs: [
          %{
            label: gettext("Products"),
            tab: :products,
            options: [navigate: ~p"/products"]
          },
          %{
            label: gettext("Stock"),
            tab: :stock,
            options: %{navigate: ~p"/stock"}
          }
        ]
      },
      %{
        label: gettext("Clients"),
        icon: "hero-user-solid",
        tab: :clients,
        options: [navigate: ~p"/clients"],
        separator: true,
        badge: 1
      },
      %{
        label: gettext("Config"),
        icon: "hero-cog-6-tooth",
        tab: :settings,
        tabs: [
          %{
            label: gettext("Account"),
            tab: :account,
            options: [navigate: ~p"/account"]
          },
          %{
            label: gettext("Notifications"),
            tab: :notifications,
            options: [navigate: ~p"/notifications"]
          }
        ]
      },
      %{
        label: gettext("Logout"),
        icon: "hero-arrow-left-end-on-rectangle-solid",
        options: [
          href: ~p"/",
          method: "delete",
          "data-confirm": gettext("¿Are you sure?")
        ]
      }
    ]
  end
end
