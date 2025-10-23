class CreateBranchRules < ActiveRecord::Migration[7.0]
  def change
    create_table :branch_rules do |t|
      t.references :survey,   null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.string     :role,     null: false
      t.boolean    :visible,  null: false, default: true
      t.timestamps
    end

    add_index :branch_rules, [:survey_id, :question_id, :role], unique: true
    add_index :branch_rules, :role
  end
end