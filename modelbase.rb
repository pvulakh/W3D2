require 'sqlite3'
require 'active_support/inflector'
require 'byebug'

require_relative "questions_db"

class ModelBase
    def self.all
        table = self.to_s.tableize
        data = QuestionsDatabase.instance.execute(<<-SQL)
            SELECT 
                *
            FROM 
                #{table}
            SQL
        data.map { |datum| self.new(datum) }
    end 

    def self.find_by_id(id)
        table = self.to_s.tableize
        found = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
              *
            FROM
              #{table}
            WHERE
              id = ?
        SQL
        return nil unless found.length > 0
        self.new(found.first)
    end

    def initialize
    end 

 

    # def save(table)
    #     # if self.id 
    #     #     self.update 
    #     # else 
    #     #     QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.user_id)
    #     #         INSERT INTO
    #     #             questions (title, body, user_id)
    #     #         VALUES 
    #     #             (?, ?, ?)
    #     #         SQL
    #     #     self.id = QuestionsDatabase.instance.last_insert_row_id
    #     # end 
    # end 

end 