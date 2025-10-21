class AddRoleToResponses < ActiveRecord::Migration[7.0]
  def change
    add_column :responses, :role, :string, null: true
    add_index  :responses, :role
  end
end