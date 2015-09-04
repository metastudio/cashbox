namespace :db do
  desc 'Fix old transfers'
  task fix_old_transfers: :environment do
    Transaction.where(category_id: Category.receipt_id, transfer_out_id: nil).each do |t|
      t.transfer_out_id = Transaction.where('category_id = ? AND amount_cents < 0 AND created_at BETWEEN ? AND ?',
        Category.transfer_out_id, t.created_at - 1.seconds, t.created_at + 1.seconds).first.id
      t.save
    end
  end
end
