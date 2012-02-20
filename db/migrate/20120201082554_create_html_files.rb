class CreateHtmlFiles < ActiveRecord::Migration
  def change
    create_table :html_files do |t|
      t.string :url
      t.string :url_hash
      t.string :content_type
      t.integer :content_size
      t.text :body

      t.timestamps
    end
  end
end
