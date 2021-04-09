defmodule OneSignal.ParamTest do
  use ExUnit.Case
  import OneSignal.Param
  import Hammox

  setup :verify_on_exit!

  test "put message" do
    param =
      OneSignal.new()
      |> put_message(:en, "Hello")
      |> put_message(:ja, "はろー")

    assert param.messages == %{:en => "Hello", :ja => "はろー"}
  end

  test "put message without specifying languages" do
    param = OneSignal.new() |> put_message("Hello")
    assert param.messages == %{:en => "Hello"}
  end

  test "put heading" do
    param =
      OneSignal.new()
      |> put_heading("Title")

    assert param.headings == %{:en => "Title"}

    param =
      OneSignal.new()
      |> put_heading(:en, "Title")
      |> put_heading(:ja, "タイトル")

    assert param.headings == %{:en => "Title", :ja => "タイトル"}
  end

  test "put segment" do
    param =
      OneSignal.new()
      |> put_segment("Free Players")
      |> put_segment("New Players")

    refute Enum.empty?(param.included_segments)

    assert Enum.all?(
             param.included_segments,
             &(&1 in ["Free Players", "New Players"])
           )
  end

  test "put segments" do
    segs = ["Free Players", "New Players"]
    param = put_segments(OneSignal.new(), segs)
    refute Enum.empty?(param.included_segments)
    assert Enum.all?(param.included_segments, &(&1 in segs))
  end

  test "drop segment" do
    segs = ["Free Players", "New Payers"]

    param =
      OneSignal.new()
      |> put_segments(segs)
      |> drop_segments(segs)

    assert Enum.empty?(param.included_segments)
  end

  test "exclude segment" do
    param =
      OneSignal.new()
      |> exclude_segment("Free Players")
      |> exclude_segment("New Players")

    assert Enum.all?(
             param.excluded_segments,
             &(&1 in ["Free Players", "New Players"])
           )
  end

  test "exclude segments" do
    segs = ["Free Players", "New Players"]
    param = exclude_segments(OneSignal.new(), segs)
    refute Enum.empty?(param.excluded_segments)
    assert Enum.all?(param.excluded_segments, &(&1 in segs))
  end

  test "build parameter" do
    param =
      OneSignal.new()
      |> put_heading("Welcome!")
      |> put_message(:en, "Hello")
      |> put_message(:ja, "はろー")
      |> exclude_segment("Free Players")
      |> exclude_segment("New Players")
      |> build

    assert param["contents"]
    assert param["app_id"]
    assert param["headings"]
    assert param["excluded_segments"]
  end

  test "push notification" do
    TestHttpClient
    |> expect(:post, fn _url, _body ->
      {:ok, success()}
    end)

    notified =
      OneSignal.new()
      |> put_heading("Welcome!")
      |> put_message(:en, "Hello")
      |> put_message(:ja, "はろー")
      |> put_segment("Free Players")
      |> put_segment("New Players")
      |> notify

    assert %OneSignal.Notification{} = notified
  end

  test "push notification with filter" do
    TestHttpClient
    |> expect(:post, fn _url, _body ->
      {:ok, success()}
    end)

    notified =
      OneSignal.new()
      |> put_heading("Welcome!")
      |> put_message(:en, "Hello")
      |> put_message(:ja, "はろー")
      |> put_filter(%{field: "tag", key: "userId", value: "123", relation: "="})
      |> notify

    assert %OneSignal.Notification{} = notified
  end

  test "put player id" do
    param = put_player_id(OneSignal.new(), "aiueo")
    refute Enum.empty?(param.include_player_ids)
  end

  test "exclude player id" do
    param = exclude_player_id(OneSignal.new(), "aiueo")
    refute Enum.empty?(param.exclude_player_ids)
  end

  test "put data" do
    world =
      OneSignal.new()
      |> put_data("Hello", "World!")
      |> build
      |> get_in(["data", "Hello"])

    assert world == "World!"
  end

  test "put thread_id" do
    param = put_thread_id(OneSignal.new(), "1")
    assert param.thread_id == "1"
  end

  test "put summary_arg" do
    param = put_summary_arg(OneSignal.new(), "bogus summary")
    assert param.summary_arg == "bogus summary"
  end

  test "put summary_arg_count" do
    param = put_summary_arg_count(OneSignal.new(), "4")
    assert param.summary_arg_count == "4"
  end

  test "put content_available" do
    param = put_content_available(OneSignal.new(), true)
    assert param.content_available == true
  end

  test "put set_sound" do
    param = set_sound(OneSignal.new(), "test.wav")
    assert param.ios_sound == "test.wav"
  end

  test "increases badgeCount" do
    param = set_badge(OneSignal.new(), :increase, 10)
    assert param.ios_badgeType == "Increase"
    assert param.ios_badgeCount == 10
  end

  test "sets badgeCount" do
    param = set_badge(OneSignal.new(), :set, 5)
    assert param.ios_badgeType == "SetTo"
    assert param.ios_badgeCount == 5
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
