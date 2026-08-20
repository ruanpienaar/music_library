defmodule MusicLibraryWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use MusicLibraryWeb, :controller` and
  `use MusicLibraryWeb, :live_view`.
  """
  use MusicLibraryWeb, :html

# What actually happens in embed_templates:
# layouts.ex has this line:
# embed_templates "layouts/*"
# That's a macro that scans the layouts/ folder and, for every something.html.heex file it finds, generates a function def something(assigns) on the MusicLibraryWeb.Layouts module. So right now, effectively, you have (invisibly, generated at compile time):
# def app(assigns), do: ~H"""...contents of app.html.heex..."""
# def app_collage(assigns), do: ~H"""...contents of app_collage.html.heex..."""

  embed_templates "layouts/*"

  def main_nav(assigns) do
    ~H"""
    <div class="flex items-center justify-between py-3">
      <a href="/" class="text-lg font-bold text-zinc-900">Music Library</a>
      <nav class="flex items-center gap-6 text-sm font-medium text-zinc-600">
        <.link navigate="/" class="hover:text-zinc-900">Dashboard</.link>
        <.link navigate="/today" class="hover:text-zinc-900">Today</.link>
        <.link navigate="/on-this-day" class="hover:text-zinc-900">On This Day</.link>
        <.link navigate="/decades" class="hover:text-zinc-900">Decades</.link>
        <.link navigate="/artists" class="hover:text-zinc-900">Artists</.link>
        <.link navigate="/tracks" class="hover:text-zinc-900">Tracks</.link>
        <.link navigate="/collage" class="hover:text-zinc-900">Collage</.link>
      </nav>
    </div>
    """
  end
end
