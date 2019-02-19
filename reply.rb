require 'sqlite3'

require_relative "questions_db"
require_relative "user"
require_relative "question"
require_relative "question_follow"
require_relative "question_like"

class Reply
    attr_accessor :id, :parent_id, :body, :subject_question_id, :author_id

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM replies')
        data.map { |datum| Reply.new(datum) }
    end

    def self.find_by_id(id)
        reply = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
              *
            FROM
              replies
            WHERE
              id = ?
        SQL
        return nil unless reply.length > 0
        Reply.new(reply.first)
    end

    #our table has user_id as author_id
    def self.find_by_user_id(user_id)
        replies = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
              *
            FROM
              replies
            WHERE
              author_id = ?
        SQL
        return nil unless replies.length > 0
        replies.map { |reply| Reply.new(reply) }
    end

    #our table has question_id as subject_question_id
    def self.find_by_question_id(question_id)
        #WE CHANGED FROM REPLY.FIRST AND ALSO VAR NAMES
        replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
                *
            FROM
                replies
            WHERE
                subject_question_id = ?
        SQL

        return nil unless replies.length > 0
        replies.map { |reply| Reply.new(reply) }
    end

    def initialize(options)
        @id = options['id']
        @parent_id = options['parent_id']
        @body = options['body']
        @subject_question_id = options['subject_question_id']
        @author_id = options['author_id']
    end 

    def save
        if self.id 
            self.update 
        else 
            QuestionsDatabase.instance.execute(<<-SQL, self.parent_id, self.body, self.subject_question_id, self.author_id)
                INSERT INTO
                    replies (parent_id, body, subject_question_id, author_id)
                VALUES 
                    (?, ?, ?, ?)
                SQL
            self.id = QuestionsDatabase.instance.last_insert_row_id
        end 
    end

    def update
        raise "#{self} not in database" unless self.id 
        QuestionsDatabase.instance.execute(<<-SQL, self.parent_id, self.body, self.subject_question_id, self.author_id, self.id) 
            UPDATE 
                replies
            SET 
                parent_id = ?, body = ?, subject_question_id = ?, author_id = ?
            WHERE 
                id = ?
        SQL
    end

    def author
        full_name =  QuestionsDatabase.instance.execute(<<-SQL, self.author_id)
            SELECT
              fname, lname
            FROM
              users
            WHERE
              id = ?
        SQL
        return nil unless full_name.length > 0
        hash_name = full_name.first
        hash_name['fname'] + ' ' + hash_name['lname']
    end

    def question
        Question.find_by_id(self.subject_question_id)
    end

    def parent_reply
        Reply.find_by_id(self.parent_id)
    end

    def child_replies
        replies = QuestionsDatabase.instance.execute(<<-SQL, self.id)
            SELECT
              *
            FROM
              replies
            WHERE
              parent_id = ?
        SQL
        return nil unless replies.length > 0
        replies.map { |reply| Reply.new(reply) }
    end
end