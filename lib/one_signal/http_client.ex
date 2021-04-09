defmodule OneSignal.HTTPClient do
  @callback post(url :: String.t(), body :: String.t()) ::
              {:ok,
               %{
                 status: 200..599,
                 headers: [{binary(), binary()}],
                 body: binary()
               }}
              | {:error, term()}
end

defmodule OneSignal.HTTPClient.HTTPoison do
  @behaviour OneSignal.HTTPClient

  @impl true
  def post(url, body) do
    HTTPoison.start()

    case HTTPoison.post(url, body, OneSignal.auth_header()) do
      {:ok, %HTTPoison.Response{body: body, status_code: status, headers: headers}} ->
        {:ok,
         %{
           status: status,
           headers: headers,
           body: body
         }}

      {:error, %HTTPoison.Error{} = error} ->
        {:error, HTTPoison.Error.message(error)}
    end
  end
end
