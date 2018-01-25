class MainPageChannel < ApplicationCable::Channel
  def subscribed
    organization_name = params[:organization]
    if current_user.organizations.map{ |o| o.name }.include?(organization_name)
      stream_from "main_page_#{organization_name}"
    end
  end
end
