json.extract! member, :id, :role, :last_visited_at

if member.user.present?
  json.user member.user, partial: 'api/v1/users/user', as: :user
end
