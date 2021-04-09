defmodule OneSignal.API do
  def post(url, body) do
    req_body = OneSignal.json_library().encode!(body)

    OneSignal.http_client().post(url, req_body)
    |> handle_response
  end

  defp handle_response({:ok, %{body: body, status: code}})
       when code in 200..299 do
    {:ok, OneSignal.json_library().decode!(body)}
  end

  defp handle_response({:ok, %{body: body, status: _}}) do
    {:error, OneSignal.json_library().decode!(body)}
  end

  defp handle_response({:error, error}) do
    {:error, error}
  end
end
