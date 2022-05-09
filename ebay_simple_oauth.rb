require 'net/http'

# One example to echange oauth code to access token in Rails
# https://developer.ebay.com/api-docs/static/oauth-auth-code-grant-request.html

def callback
  # https://developer.ebay.com/my/auth?env=sandbox&index=0
  # You have to setup your ebay sign-in settings
  # Your auth accepted URL should be this callback

  # After sign-in by user, ebay redirect to callback url with params[:code]
  code = params["code"]

  # Refer to https://developer.ebay.com/my/keys
  client_id = ENV["EBAY_CLIENT_ID"]
  client_secret = ENV["EBAY_CLIENT_SECRET"]

  # For sandbox
  oauth_endpoint = "https://api.sandbox.ebay.com/identity/v1/oauth2/token"

  post_params = {
    grant_type: "authorization_code",
    code: code,
    redirect_uri: ENV["EBAY_RU_NAME"]
  }

  # use Base64.strict_encode64()
  authorization = Base64.strict_encode64(client_id + ":" + client_secret)

  headers = {
    "Content-Type": "application/x-www-form-urlencoded",
    "Authorization": "Basic " + authorization
  }

  uri = URI.parse(oauth_endpoint)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = uri.scheme === "https"
  # For debug use uncomment this
  # http.set_debug_output($stderr)

  response = http.post(uri.path, post_params.to_query, headers)

  response_body = response.body

  response_data = JSON.parse(response_body)

  access_token = response_data["access_token"]
  refresh_token = response_data["refresh_token"]
  expires_in = response_data["expires_in"]
  refresh_token_expires_in = response_data["refresh_token_expires_in"]

end