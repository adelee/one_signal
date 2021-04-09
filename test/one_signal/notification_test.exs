defmodule OneSignal.NotificationTest do
  use ExUnit.Case

  import Hammox

  setup :verify_on_exit!

  test "sends notification" do
    TestHttpClient
    |> expect(:post, fn _url, _body ->
      {:ok, success()}
    end)

    notification = OneSignal.new()

    OneSignal.Notification.send(notification)
  end

  defp success() do
    %{
      status: 200,
      body:
        %{
          id: "b98881cc-1e94-4366-bbd9-db8f3429292b",
          recipients: 1,
          external_id: nil
        }
        |> Jason.encode!(),
      headers: []
    }
  end
end
