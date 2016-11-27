class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :giftor, null: false, default: 0
      t.integer :giftee, null: false, default: 0
      t.string :phone

      t.timestamps
    end
  end
end
