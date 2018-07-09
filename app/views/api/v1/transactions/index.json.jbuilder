json.transactions @transactions, partial: 'transaction', as: :transaction
json.pagination pagination_info(@transactions)
