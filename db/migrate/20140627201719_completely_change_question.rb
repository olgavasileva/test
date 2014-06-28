class CompletelyChangeQuestion < ActiveRecord::Migration
  def up
    drop_table :questions

    create_table :questions do |t|
      t.integer  :user_id
      t.integer  :category_id
      t.string   :title
      t.string   :description
      t.boolean  :rotate
      t.string   :type
      t.integer  :position
      t.boolean  :show_question_results
      t.integer  :weight
      t.string   :image
      t.string   :html
      t.string   :text_type
      t.integer  :min_characters
      t.integer  :max_characters
      t.integer  :min_responses
      t.integer  :max_responses
      t.integer  :max_stars
    end

    add_index :questions, :user_id
    add_index :questions, :category_id
  end

  def down
    drop_table :questions

    create_table :questions do |t|
      t.string   :title
      t.string   :info
      t.string   :image_url
      t.integer  :question_type
      t.integer  :user_id
      t.integer  :category_id
      t.integer  :min_value
      t.integer  :max_value
      t.integer  :interval
      t.string   :units
      t.boolean  :hidden,        default: false
      t.boolean  :special_case,  default: false
      t.boolean  :sponsored,     default: false
    end

    add_index :questions, :category_id
    add_index :questions, :user_id
  end
end
