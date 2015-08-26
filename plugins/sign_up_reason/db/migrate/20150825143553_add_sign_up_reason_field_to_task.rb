class AddSignUpReasonFieldToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :signup_reason, :string
  end

  def self.down
    remove_column :tasks, :signup_reason
  end
end
