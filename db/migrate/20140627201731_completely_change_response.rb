class CompletelyChangeResponse < ActiveRecord::Migration
  def up
    drop_table :responses
    drop_table :answers

    create_table :responses do |t|
      t.string   :type
      t.integer  :user_id
      t.integer  :question_id
      t.string   :image
      t.string   :text
      t.integer  :choice_id
      t.integer  :stars
      t.float    :percent
      t.integer  :position

      t.timestamps
    end

    add_index :responses, :choice_id
    add_index :responses, :question_id
    add_index :responses, :user_id
  end

  def down
    drop_table :responses

    create_table :responses do |t|
      t.integer  :order
      t.float    :percent
      t.integer  :star
      t.integer  :choice_id
      t.integer  :answer_id
      t.integer  :slider

      t.timestamps
    end

    add_index :responses, :answer_id
    add_index :responses, :choice_id


    create_table :answers do |t|
      t.integer  :user_id
      t.integer  :question_id
      t.boolean  :agree

      t.timestamps
    end

    add_index :answers, :question_id
    add_index :answers, [:user_id, :question_id], unique: true
    add_index :answers, :user_id
  end
end
