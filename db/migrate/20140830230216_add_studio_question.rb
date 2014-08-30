class AddStudioQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :studio_id, :integer, index: true
    add_column :responses, :scene_id, :integer, index: true

    create_table :galleries do |t|
      t.datetime :entries_open
      t.datetime :entries_close
      t.datetime :voting_open
      t.datetime :voting_close
      t.integer  :total_votes
      t.integer  :user_id, index: true
      t.references :gallery_template, index: true
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :gallery_templates do |t|
      t.string   :name
      t.string   :description
      t.string   :image
      t.boolean  :contest,         default: false
      t.text     :rules
      t.string   :recurrence
      t.datetime :entries_open
      t.datetime :entries_close
      t.datetime :voting_open
      t.datetime :voting_close
      t.integer  :num_occurrences
      t.references  :studio, index: true
      t.integer  :max_votes
      t.datetime :created_at
      t.datetime :updated_at
      t.text     :confirm_message
      t.integer  :num_winners
    end

    create_table :gallery_elements do |t|
      t.references  :scene, index: true
      t.references  :gallery, index: true
      t.references  :user, index: true
      t.integer  :votes
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :gallery_element_votes do |t|
      t.references  :gallery_element, index: true
      t.integer  :votes
      t.datetime :created_at
      t.datetime :updated_at
      t.references  :user, index: true
    end

    create_table :scenes do |t|
      t.text     :canvas_json
      t.references  :user, index: true
      t.boolean  :deleted,     default: false
      t.string   :name
      t.references  :studio, index: true
      t.string   :image
      t.datetime :created_at
      t.datetime :updated_at
    end

    create_table :sticker_pack_stickers do |t|
      t.references :sticker_pack, index: true
      t.references :sticker, index: true
      t.integer :sort_order
    end

    create_table :sticker_packs do |t|
      t.string   :display_name
      t.boolean  :disabled
      t.string   :klass
      t.string   :header_icon
      t.string   :footer_image
      t.string   :footer_link
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :starts_at
      t.datetime :expires_at
    end

    create_table :stickers do |t|
      t.string   :display_name
      t.string   :kind
      t.boolean  :mirrorable
      t.integer  :priority
      t.string   :image
      t.integer  :image_width
      t.integer  :image_height
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean  :spotlightable
      t.boolean  :disabled
    end

    create_table :studio_sticker_packs do |t|
      t.references :sticker_pack, index: true
      t.integer :sort_order
      t.references :studio, index: true
    end

    create_table :studios do |t|
      t.string   :name
      t.string   :display_name
      t.boolean  :disabled,        default: true
      t.references  :affiliate, index: true
      t.references  :contest, index: true
      t.references  :scene, index: true
      t.text     :welcome_message
      t.references  :sticker_pack, index: true
      t.datetime :starts_at
      t.datetime :expires_at
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :image
      t.string   :icon
    end
  end
end
