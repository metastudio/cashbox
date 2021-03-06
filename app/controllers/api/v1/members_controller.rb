module Api::V1
  class MembersController < BaseOrganizationController
    before_action :set_member, only: %i[show update destroy]

    def_param_group :member do
      param :member, Hash, required: true, action_aware: true do
        param :role, String, 'Role', required: true
        param :last_visited_at, DateTime, 'DateTime of last visited'
      end
    end

    api :GET, '/organizations/:organization_id/members', 'Return members of current organization'
    def index
      @members = current_organization.members.ordered.includes(:user)
    end

    api :PUT, '/organizations/:organization_id/members/:id', 'Update member'
    param_group :member, MembersController
    def update
      if @member.update(member_params)
        render json: {}, status: :ok
      else
        render json: @member.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/organizations/:organization_id/members/:id', 'Destroy member'
    def destroy
      @member.destroy
    end

    api :GET, '/organizations/:organization_id/members/:id', 'Return member'
    def show
    end

    api :PUT, '/organizations/:organization_id/last_visit', 'Update last viewed at for current member'
    def update_last_visit
      if current_member.update(last_visited_at: params[:last_visited_at].presence || Time.current)
        render json: current_member, status: :ok
      else
        render json: current_member.errors, status: :unprocessable_entity
      end
    end

    private

    def set_member
      @member = current_organization.members.find(params[:id])
      authorize @member
    end

    def member_params
      params.require(:member).permit(:role)
    end

    def pundit_user
      MemberContext.new(current_user.members.find_by(organization: current_organization), params)
    end
  end
end
