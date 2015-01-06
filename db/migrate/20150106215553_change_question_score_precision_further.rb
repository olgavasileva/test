class ChangeQuestionScorePrecisionFurther < ActiveRecord::Migration
  def change
    change_column :questions, :score, :decimal, default: 0, precision: 10, scale: 2
  end
end
