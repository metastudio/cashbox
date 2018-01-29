json.extract! organization_invitation, :id, :email, :role, :accepted
json.invited_by organization_invitation.invited_by,
  partial: 'api/v1/members/member', as: :member
