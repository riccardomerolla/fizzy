module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def searchable_by(field, using:)
      define_method :search_field do field; end
      define_method :search_table do using; end

      after_create_commit  :create_in_search_index
      after_update_commit  :update_in_search_index
      after_destroy_commit :remove_from_search_index

      scope :search, ->(query) { joins("join #{using} idx on #{table_name}.id = idx.rowid").where("idx.#{field} match ?", query) }
    end
  end

  private
    def create_in_search_index
      execute_sql_with_binds "insert into #{search_table}(rowid, #{search_field}) values (?, ?)", id, send(search_field)
    end

    def update_in_search_index
      execute_sql_with_binds "update #{search_table} set #{search_field} = ? where rowid = ?", send(search_field), id
    end

    def remove_from_search_index
      execute_sql_with_binds "delete from #{search_table} where rowid = ?", id
    end

    def execute_sql_with_binds(*statement)
      self.class.connection.execute self.class.sanitize_sql(statement)
    end
end
