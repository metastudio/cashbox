class HomeController < ApplicationController
  before_action :require_organization
  before_action :redirect_for_not_ready_organization
  after_action :update_last_viewed_at

  def show
    @q = current_organization.transactions.ransack(params[:q])
    @q.sorts = ['date desc', 'created_at desc'] if @q.sorts.blank?
    @transactions = @q.result

    @curr_flow = @transactions.flow_ordered(current_organization.default_currency) if params[:q]

    respond_to do |format|
      format.any(:js, :html) do
        if params[:q] && params[:q][:category_type_eq]
          @transactions = @transactions.page(params[:page]).per(50)
        else
          @transactions = @transactions.without_out(@q.bank_account_id_in).page(params[:page]).per(50)
        end
      end

      format.csv do
        filename = ['transactions', Date.today.strftime("%Y-%m-%d")].join('_')
        send_data @transactions.to_csv, filename: filename, content_type: 'text/csv'
      end
    end

    gon.curr_org_exch_rates = current_organization.exchange_rates

    session[:filter] = params[:q]
    @transaction = Transaction.new
  end
end
