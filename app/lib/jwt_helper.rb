class JwtHelper
  def self.access_limited_preview_url(url, auth_bypass_id)
    token = jwt_token(auth_bypass_id)
    "#{url}?token=#{token}"
  end

  def self.jwt_token(auth_bypass_id)
    payload = { "sub" => auth_bypass_id,
                "asset_manager_access" => true,
                "exp" => 1.month.from_now.to_i }

    JWT.encode(payload, ENV["JWT_AUTH_SECRET"], "HS256")
  end
end
