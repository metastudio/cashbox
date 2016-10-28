module MainPageRefresher
  extend ActiveSupport::Concern
  include ActionView::Helpers

  included do
    def prepare_data(transaction)
      organization = transaction.organization
      {
        id: dom_id(transaction),
        user_id: transaction.created_by.try(:id),
        view: render_transaction(transaction),
        sidebar: render_sidebar(organization),
        total_balance: render_total_balance(organization)
      }
    end

    def render_transaction(transaction)
      TransactionsController.render(partial: 'transactions/transaction',
       locals: { transaction: transaction })
    end

    def render_sidebar(organization)
      TransactionsController.render(partial: 'home/sidebar',
        locals: { current_organization: organization })
    end

    def render_total_balance(organization)
      TransactionsController.render(partial: 'shared/layout/total_balance',
        locals: { current_organization: organization })
    end
  end
end
