class HoboMigration1 < ActiveRecord::Migration
  def self.up
    create_table :edition_assets do |t|
      t.string   :identifier
      t.string   :url
      t.integer  :edition
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :edition_pages do |t|
      t.integer  :index
      t.string   :content
      t.string   :type
      t.integer  :edition
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :editions do |t|
      t.string   :title
      t.string   :subtitle
      t.date     :date
      t.string   :identifier
      t.string   :author
      t.string   :cover
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def self.down
    drop_table :edition_assets
    drop_table :edition_pages
    drop_table :editions
  end
end
