module RequestMacros
  module OrganizationInvitation
    def returns_organization_invitations
      expect(response).to be_success
      expect(json[0]).to include(
        'id'       => invitation.id,
        'email'    => invitation.email,
        'role'     => invitation.role,
        'accepted' => invitation.accepted,
        'invited_by' => {
          'id'              => member.id,
          'role'            => member.role,
          'last_visited_at' => member.last_visited_at,
          'user' => {
            'id'           => owner.id,
            'email'        => owner.email,
            'full_name'    => owner.full_name,
            'phone_number' => owner.profile.phone_number
          }
        }
      )
    end

    def returns_organization_invitation
      expect(response).to be_success
      expect(json).to include(
        'id'       => invitation.id,
        'email'    => invitation.email,
        'role'     => invitation.role,
        'accepted' => invitation.accepted,
        'invited_by' => {
          'id'              => member.id,
          'role'            => member.role,
          'last_visited_at' => member.last_visited_at,
          'user' => {
            'id'           => owner.id,
            'email'        => owner.email,
            'full_name'    => owner.full_name,
            'phone_number' => owner.profile.phone_number
          }
        }
      )
    end
  end
end

RSpec.configure do |config|
  config.include RequestMacros::OrganizationInvitation, type: :request
end
