require 'sqlite3'

require_relative "questions_db"
require_relative "user"
require_relative "question"
require_relative "question_follow"
require_relative "reply"

class QuestionLike
    attr_accessor :id, :user_id, :question_id

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM question_likes')
        data.map { |datum| QuestionLike.new(datum) }
    end

    def self.find_by_id(id)
        question_like = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
              *
            FROM
              question_likes
            WHERE
              id = ?
        SQL
        return nil unless question_like.length > 0
        QuestionLike.new(question_like.first)
    end

    def self.likers_for_question_id(question_id)
        likers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
              *
            FROM
              users
            JOIN
              question_likes ON question_likes.user_id = users.id
            WHERE
              question_likes.question_id = ?
        SQL
        return nil unless likers.length > 0
        likers.map { |liker| User.new(liker) }
    end

    def self.num_likes_for_question_id(question_id)
        num = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
              COUNT(user_id)
            FROM
              question_likes
            WHERE
              question_id = ?
            GROUP BY
              question_id
        SQL
        num.first[0][0]
    end

    def self.liked_questions_for_user_id(user_id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
              *
            FROM
              questions
            JOIN
              question_likes ON question_likes.question_id = questions.id
            WHERE
              question_likes.user_id = ?
        SQL
        return nil unless questions.length > 0
        questions.map { |question| Question.new(question) }
    end

    def self.most_liked_questions(n)
        questions_rank = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT 
                * 
            FROM 
                questions
            JOIN question_likes ON question_likes.question_id = questions.id
            GROUP BY question_likes.question_id
            ORDER BY COUNT(question_likes.user_id) DESC LIMIT ?
        SQL
        return nil unless questions_rank.length > 0 
        questions_rank.map { |question| Question.new(question) }
    end 

    def initialize(options)
        @id, @user_id, @question_id = options['id'], options['user_id'], options['question_id']
    end 
end