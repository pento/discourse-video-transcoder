# frozen_string_literal: true
class AddTranscodedToUpload < ActiveRecord::Migration[7.2]
  def change
    add_column :uploads, :transcoded, :boolean
  end
end
