require 'sqlite3'

require_relative "questions_db"
require_relative "user"
require_relative "question_like"
require_relative "question_follow"
require_relative "reply"



class Question
    attr_accessor :id, :title, :body, :user_id

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM questions')
        data.map { |datum| Question.new(datum) }
    end
    
    def self.find_by_id(id)
        question = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
              *
            FROM
              questions
            WHERE
              id = ?
        SQL
        return nil unless question.length > 0
        Question.new(question.first)
    end

    #our table has author_id as user_id
    def self.find_by_author_id(author_id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, author_id)
            SELECT
              *
            FROM
              questions
            WHERE
              user_id = ?
        SQL
        return nil unless questions.length > 0
        questions.map { |question| Question.new(question) }
    end

    def self.most_followed(n)
        QuestionFollow.most_followed_questions(n)
    end

    def self.most_liked(n)
        QuestionLike.most_liked_questions(n)
    end 

    def initialize(options)
        @id = options['id']
        @title = options['title']
        @body = options['body']
        @user_id = options['user_id']
    end

    def save
        if self.id 
            self.update 
        else 
            QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.user_id)
                INSERT INTO
                    questions (title, body, user_id)
                VALUES 
                    (?, ?, ?)
                SQL
            self.id = QuestionsDatabase.instance.last_insert_row_id
        end 
    end

    def update
        raise "#{self} not in database" unless self.id 
        QuestionsDatabase.instance.execute(<<-SQL, self.title, self.body, self.user_id, self.id) 
            UPDATE 
                questions 
            SET 
                title = ?, body = ?, user_id = ?
            WHERE 
                id = ?
        SQL
    end

    def author
        full_name =  QuestionsDatabase.instance.execute(<<-SQL, self.user_id)
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

    def replies
        Reply.find_by_question_id(self.id)
    end
    
    def followers 
        QuestionFollow.followers_for_question_id(self.id)
    end

    def likers 
        QuestionLike.likers_for_question_id(self.id)
    end 

    def num_likes 
        QuestionLike.num_likes_for_question_id(self.id)
    end
end