defmodule YoloWatcher.Repo do
  use Ecto.Repo,
    otp_app: :yolo_watcher,
    adapter: Ecto.Adapters.Postgres
end
