module UsersHelper
  def prepend_current_user_to(users_scope)
    users_scope.to_a.prepend(Current.user).uniq
  end

  def familiar_name_for(user)
    names = user.name.split
    return user.name if names.length == 1
    "#{names.first} #{names[1..].map { |n| "#{n[0]}." }.join}"
  end
end
