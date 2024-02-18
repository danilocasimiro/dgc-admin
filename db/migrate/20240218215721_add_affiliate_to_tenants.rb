class AddAffiliateToTenants < ActiveRecord::Migration[7.1]
  def change
    add_reference :tenants, :affiliate, foreign_key: true
  end
end
