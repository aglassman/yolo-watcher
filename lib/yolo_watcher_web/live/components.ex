defmodule YoloWatcherWeb.BlackJackLive.Components do
  use Phoenix.Component

  @doc """
  Displays the suggested strategy, styled as follows:
  :stand = yellow
  :double = green
  :hit = blue
  :surrender = purple
  :split = orange
  """
  def action_badge(assigns) do
    ~H"""
    <span class="inline-flex items-center rounded-md bg-pink-50 px-2 py-1 text-4xl font-medium text-pink-700 ring-1 ring-inset ring-pink-700/10">
      <%= Phoenix.Naming.humanize(@action) %>
    </span>
    """
  end

end