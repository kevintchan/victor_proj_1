class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.references :user
      t.references :location
      t.text :text

      t.timestamps
    end
  end
end
