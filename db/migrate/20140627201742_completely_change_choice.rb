class CompletelyChangeChoice < ActiveRecord::Migration
  def up
    drop_table :choices

    create_table :choices do |t|
      t.integer  :question_id
      t.string   :title
      t.integer  :position
      t.boolean  :rotate
      t.boolean  :muex

      t.timestamps
    end

    add_index :choices, :question_id

    create_table :choices_responses do |t|
      t.integer :multiple_choice_id
      t.integer :multiple_choice_response_id

      t.timestamps
    end

    create_table :star_choices_responses do |t|
      t.integer :star_choice_id
      t.integer :star_response_id

      t.timestamps
    end

    create_table :percent_choices_responses do |t|
      t.integer :percent_choice_id
      t.integer :percent_response_id

      t.timestamps
    end

    create_table :order_choices_responses do |t|
      t.integer :order_choice_id
      t.integer :order_response_id

      t.timestamps
    end
  end

  def down
    drop_table :choices
    drop_table :choices_responses
    drop_table :star_choices_responses
    drop_table :percent_choices_responses
    drop_table :order_choices_responses

    create_table :choices do |t|
      t.string   :label
      t.string   :image_url
      t.string   :description
      t.integer  :question_id

      t.timestamps
    end

    add_index :choices, :question_id
  end
end
