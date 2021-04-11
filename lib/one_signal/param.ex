defmodule OneSignal.Param do
  alias OneSignal.Param

  defstruct adm_params: nil,
            android_channel_id: nil,
            android_params: nil,
            chrome_params: nil,
            content_available: nil,
            data: nil,
            exclude_external_user_ids: nil,
            exclude_player_ids: nil,
            excluded_segments: nil,
            filters: [],
            firefox_params: nil,
            headings: nil,
            include_external_user_ids: nil,
            include_player_ids: nil,
            included_segments: nil,
            ios_params: nil,
            ios_badgeCount: nil,
            ios_badgeType: nil,
            ios_sound: nil,
            messages: %{},
            platforms: nil,
            send_after: nil,
            summary_arg: nil,
            summary_arg_count: nil,
            thread_id: nil,
            tags: nil,
            wp_params: nil

  defp to_string_key({k, v}) do
    {to_string(k), v}
  end

  defp to_body({:headings, headings}) do
    body =
      headings
      |> Enum.map(&to_string_key/1)
      |> Enum.into(%{})

    {:headings, body}
  end

  defp to_body(body), do: body

  @doc """
  Send push notification from parameters
  """
  def notify(%Param{} = param) do
    param
    |> build
    |> OneSignal.Notification.send()
  end

  @doc """
  Build notifications parameter of request
  """
  def build(%Param{} = param) do
    required = %{
      "app_id" => OneSignal.fetch_app_id(),
      "contents" => Enum.map(param.messages, &to_string_key/1) |> Enum.into(%{}),
      "filters" => param.filters
    }

    reject_params = [
      :messages,
      :filters,
      :platforms,
      :ios_params,
      :android_params,
      :adm_params,
      :wp_params,
      :chrome_params,
      :firefox_params
    ]

    optionals =
      param
      |> Map.from_struct()
      |> Enum.reject(fn {k, v} ->
        k in reject_params or is_nil(v)
      end)
      |> Enum.map(&to_body/1)
      |> Enum.map(&to_string_key/1)
      |> Enum.into(%{})

    Map.merge(required, optionals)
  end

  @doc """
  Put message in parameters

  iex> OneSignal.new
       |> put_message(:en, "Hello")
       |> put_message(:ja, "はろー")
  """
  def put_message(%Param{} = param, message) do
    put_message(param, :en, message)
  end

  def put_message(%Param{} = param, language, message) do
    messages = Map.put(param.messages, language, message)
    %{param | messages: messages}
  end

  @doc """
  Put notification title.
  Notification title to send to Android, Amazon, Chrome apps, and Chrome Websites.

  iex> OneSignal.new
        |> put_heading("App Notice!")
        |> put_message("Hello")
  """
  def put_heading(%Param{} = param, heading) do
    put_heading(param, :en, heading)
  end

  def put_heading(%Param{headings: nil} = param, language, heading) do
    %{param | headings: %{language => heading}}
  end

  def put_heading(%Param{headings: headings} = param, language, heading) do
    headings = Map.put(headings, language, heading)
    %{param | headings: headings}
  end

  @doc """
  Put specific target segment

  iex> OneSignal.new
        |> put_message("Hello")
        |> put_segment("Top-Rank")
  """
  def put_segment(%Param{included_segments: nil} = param, segment) do
    %{param | included_segments: [segment]}
  end

  def put_segment(%Param{included_segments: seg} = param, segment) do
    %{param | included_segments: [segment | seg]}
  end

  @doc """
  Put specific filter

  iex> OneSignal.new
        |> put_message("Hello")
        |> put_filter("{userId: asdf}")
  """
  def put_filter(%Param{filters: filters} = param, filter) do
    %{param | filters: [filter | filters]}
  end

  @doc """
  Put segments
  """
  def put_segments(%Param{} = param, segs) do
    Enum.reduce(segs, param, fn next, acc -> put_segment(acc, next) end)
  end

  @doc """
  Drop specific target segment

  iex> OneSignal.new
       |> put_segment("Free Players")
       |> drop_segment("Free Players")
  """
  def drop_segment(%Param{included_segments: nil} = param, _seg) do
    param
  end

  def drop_segment(%Param{} = param, seg) do
    segs = Enum.reject(param.included_segments, &(&1 == seg))
    %{param | included_segments: segs}
  end

  @doc """
  Drop specific target segments
  """
  def drop_segments(%Param{} = param, segs) do
    Enum.reduce(segs, param, fn next, acc -> drop_segment(acc, next) end)
  end

  @doc """
  Exclude specific segment
  """
  def exclude_segment(%Param{excluded_segments: nil} = param, seg) do
    %{param | excluded_segments: [seg]}
  end

  def exclude_segment(%Param{excluded_segments: segs} = param, seg) do
    %{param | excluded_segments: [seg | segs]}
  end

  @doc """
  Exclude segments
  """
  def exclude_segments(%Param{} = param, segs) do
    Enum.reduce(segs, param, fn next, acc -> exclude_segment(acc, next) end)
  end

  @doc """
  Put external user id
  """
  def put_external_user_id(%Param{include_external_user_ids: nil} = param, user_id) do
    %{param | include_external_user_ids: [user_id]}
  end

  def put_external_user_id(%Param{include_external_user_ids: ids} = param, user_id) do
    %{param | include_external_user_ids: [user_id | ids]}
  end

  def put_external_user_ids(%Param{} = param, user_ids) when is_list(user_ids) do
    Enum.reduce(user_ids, param, fn next, acc ->
      put_external_user_id(acc, next)
    end)
  end

  @doc """
  Exclude external user id
  """
  def exclude_external_user_id(%Param{exclude_external_user_ids: nil} = param, user_id) do
    %{param | exclude_external_user_ids: [user_id]}
  end

  def exclude_external_user_id(%Param{exclude_external_user_ids: ids} = param, user_id) do
    %{param | exclude_external_user_ids: [user_id | ids]}
  end

  def exclude_external_user_ids(%Param{} = param, user_ids) when is_list(user_ids) do
    Enum.reduce(user_ids, param, fn next, acc ->
      exclude_external_user_id(acc, next)
    end)
  end

  @doc """
  Put player id
  """
  def put_player_id(%Param{include_player_ids: nil} = param, player_id) do
    %{param | include_player_ids: [player_id]}
  end

  def put_player_id(%Param{include_player_ids: ids} = param, player_id) do
    %{param | include_player_ids: [player_id | ids]}
  end

  def put_player_ids(%Param{} = param, player_ids) when is_list(player_ids) do
    Enum.reduce(player_ids, param, fn next, acc ->
      put_player_id(acc, next)
    end)
  end

  @doc """
  Exclude player id
  """
  def exclude_player_id(%Param{exclude_player_ids: nil} = param, player_id) do
    %{param | exclude_player_ids: [player_id]}
  end

  def exclude_player_id(%Param{exclude_player_ids: ids} = param, player_id) do
    %{param | exclude_player_ids: [player_id | ids]}
  end

  def exclude_player_ids(%Param{} = param, player_ids) when is_list(player_ids) do
    Enum.reduce(player_ids, param, fn next, acc ->
      exclude_player_id(acc, next)
    end)
  end

  @doc """
  Put data

  A custom map of data that is passed back to your app. Same as using Additional Data within the dashboard. Can use up to 2048
  bytes of data.

  Example: {"abc": 123, "foo": "bar", "event_performed": true, "amount": 12.1}
  """
  def put_data(%Param{data: nil} = param, key, value) do
    %{param | data: %{key => value}}
  end

  def put_data(%Param{data: data} = param, key, value) do
    %{param | data: Map.put(data, key, value)}
  end

  def put_data(%Param{data: nil} = param, map) when is_map(map) do
    %{param | data: map}
  end

  def put_data(%Param{data: data} = param, map) when is_map(map) do
    %{param | data: Map.merge(data, map)}
  end

  @doc """
  Put content available

  See https://documentation.onesignal.com/reference/create-notification#notification-content
  """
  def put_content_available(%Param{} = param, content_available)
      when is_boolean(content_available) do
    %{param | content_available: content_available}
  end

  @doc """
  Put thread_id

  This parameter is supported in iOS 12 and above. It allows you to group related notifications together.

  If two notifications have the same thread-id, they will both be added to the same group.

  iOS 12+
  """
  def put_thread_id(%Param{} = param, thread_id) do
    %{param | thread_id: thread_id}
  end

  @doc """
  Put summary_arg

  When using thread_id to create grouped notifications in iOS 12+, you can also control the summary.
  For example, a grouped notification can say "12 more notifications from John Doe".

  The summary_arg lets you set the name of the person/thing the notifications are coming from, and will
  show up as "X more notifications from summary_arg"

  iOS 12+
  """
  def put_summary_arg(%Param{} = param, summary_arg) do
    %{param | summary_arg: summary_arg}
  end

  @doc """
  Put summary_arg_count

  When using thread_id, you can also control the count of the number of notifications in the group.
  For example, if the group already has 12 notifications, and you send a new notification with
  summary_arg_count = 2, the new total will be 14 and the summary will be
  "14 more notifications from summary_arg"

  iOS 12+
  """
  def put_summary_arg_count(%Param{} = param, summary_arg_count) do
    %{param | summary_arg_count: summary_arg_count}
  end

  @doc """
  Set android channel/category for notification
  """
  def set_android_channel_id(param, channel_id) do
    %{param | android_channel_id: channel_id}
  end

  @doc """
  Set ios badge

  Use negative value together with `:increase` to decrease badge count
  """
  def set_badge(%Param{} = params, action, badge_count) when is_integer(badge_count) do
    %{params | ios_badgeType: badge_type(action), ios_badgeCount: badge_count}
  end

  @doc """
  Sound file that is included in your app to play instead of the default device notification sound. Pass nil
  to disable vibration and sound for the notification.
  """
  def set_sound(%Param{} = params, sound_file_name) when is_binary(sound_file_name) do
    %{params | ios_sound: sound_file_name}
  end

  defp badge_type(:increase), do: "Increase"
  defp badge_type(:set), do: "SetTo"
  defp badge_type(_), do: badge_type(:set)
end
