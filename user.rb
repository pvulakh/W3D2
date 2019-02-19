require 'sqlite3'

require_relative "questions_db"
require_relative "question_like"
require_relative "question"
require_relative "question_follow"
require_relative "reply"
require 'byebug'

class User

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM users')
        data.map { |datum| User.new(datum) }
    end

    def self.find_by_id(id)
        user = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
              *
            FROM
              users
            WHERE
              id = ?
        SQL
        return nil unless user.length > 0
        User.new(user.first)
    end

    def self.find_by_name(fname, lname)
        user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
            SELECT
              *
            FROM
              users
            WHERE
              fname = ? AND lname = ?
        SQL
        return nil unless user.length > 0
        User.new(user.first)
    end

    attr_accessor :id, :fname, :lname

    def initialize(options)
        @id, @fname, @lname, = options['id'], options['fname'], options['lname'] 
    end 

    def save
        if self.id 
            self.update 
        else 
            QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname)
                INSERT INTO
                    users (fname, lname)
                VALUES 
                    (?, ?)
                SQL
            self.id = QuestionsDatabase.instance.last_insert_row_id
        end 
    end

    def update
        raise "#{self} not in database" unless self.id 
        QuestionsDatabase.instance.execute(<<-SQL, self.fname, self.lname, self.id) 
            UPDATE 
                users 
            SET 
                fname = ?, lname = ?
            WHERE 
                id = ?
        SQL
    end 

    def authored_questions
        Question.find_by_author_id(self.id)
    end

    def authored_replies
        Reply.find_by_user_id(self.id)
    end

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(self.id)
    end 

    def liked_questions
        QuestionLike.liked_questions_for_user_id(self.id)
    end 

    def average_karma
        question_stats = QuestionsDatabase.instance.execute(<<-SQL)
            SELECT 
                COUNT(question_likes.question_id) / CAST(COUNT(DISTINCT(questions.user_id)) AS FLOAT)
            FROM 
                question_likes 
            JOIN
                questions ON questions.id = question_likes.question_id
            GROUP BY
                question_likes.question_id
        SQL
        question_stats[0][0]
     end 
end