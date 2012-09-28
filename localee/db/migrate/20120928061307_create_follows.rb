class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows, :id => false do |t|
      t.references :user
      t.references :location

      t.timestamps
    end
  end
end
