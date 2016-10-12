json.extract! member, :id, :role

if member.user.present?
  json.user member.user, partial: 'api/v1/users/user', as: :user
end
