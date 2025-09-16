json.cache! user do
  json.(user, :id, :name, :email_address, :role, :active)

  json.created_at user.created_at.utc

  json.url user_url(user)
end
