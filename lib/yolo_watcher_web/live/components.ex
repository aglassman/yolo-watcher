defmodule YoloWatcherWeb.BlackJackLive.Components do
  use Phoenix.Component

  @doc """
  Displays the suggested strategy, styled as follows:
  :stand = yellow
  :double = green
  :hit = blue
  :surrender = purple
  :split = orange
  :split_and_double = orange
  """
  def action_badge(assigns) do
    color =
      case assigns.action do
        :stand -> "yellow"
        :double -> "green"
        :hit -> "blue"
        :surrender -> "purple"
        :split -> "indigo"
        :split_and_double -> "indigo"
        _ -> "gray"
      end

    assigns =
      assign(assigns, :color_classes, "bg-#{color}-50 text-#{color}-800 ring-#{color}-700/10")

    ~H"""
    <span class={[
      "inline-flex items-center rounded-md px-2 py-1 text-4xl font-medium ring-1 ring-inset",
      @color_classes
    ]}>
      <%= Phoenix.Naming.humanize(@action) %>
    </span>
    """
  end
end
