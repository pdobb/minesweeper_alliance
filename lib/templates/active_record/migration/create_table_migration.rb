# frozen_string_literal: true

# Version: <%= migration_number %>
class <%= migration_class_name %> < ActiveRecord::Migration[<%= ActiveRecord::Migration.current_version %>]
  def change
    create_table :<%= table_name %><%= primary_key_type %> do |t|
<% attributes.each do |attribute| -%>
<% if attribute.password_digest? -%>
      t.string :password_digest<%= attribute.inject_options %>
<% elsif attribute.token? -%>
      t.string :<%= attribute.name %><%= attribute.inject_options %>
<% elsif attribute.reference? -%>
      t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %><%= foreign_key_type %>
<% elsif !attribute.virtual? -%>
      t.<%= attribute.type %> :<%= attribute.name %><%= attribute.inject_options %>
<% end -%>
<% end -%>
<% unless attributes.empty? -%>

<% end -%>
<% if options[:timestamps] -%>
      t.timestamps
<% end -%>
    end
<% attributes.select(&:token?).each do |attribute| -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>, unique: true
<% end -%>
<% attributes_with_index.each do |attribute| -%>
    add_index :<%= table_name %>, :<%= attribute.index_name %><%= attribute.inject_index_options %>
<% end -%>
  end
end
