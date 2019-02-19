require 'sqlite3'

require_relative "questions_db"
require_relative "user"
require_relative "question"
require_relative "question_like"
require_relative "reply"

class QuestionFollow
    attr_accessor :id, :user_id, :question_id

    def self.all
        data = QuestionsDatabase.instance.execute('SELECT * FROM question_follows')
        data.map { |datum| QuestionFollow.new(datum) }
    end

    def self.find_by_id(id)
        question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)
            SELECT
              *
            FROM
              question_follows
            WHERE
              id = ?
        SQL
        return nil unless question_follow.length > 0
        QuestionFollow.new(question_follow.first)
    end

    def self.followers_for_question_id(question_id)
        question_follow = QuestionsDatabase.instance.execute(<<-SQL, question_id)
            SELECT
              *
            FROM
              users
            JOIN
              question_follows ON question_follows.user_id = users.id
            WHERE
              question_follows.question_id = ?
        SQL
        return nil unless question_follow.length > 0
        question_follow.map { |user| User.new(user) }
    end

    def self.followed_questions_for_user_id(user_id)
        questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
            SELECT
              *
            FROM
              questions
            JOIN
              question_follows ON question_follows.question_id = questions.id
            WHERE
              question_follows.user_id = ?
        SQL
        return nil unless questions.length > 0
        questions.map { |question| Question.new(question) }
    end 

    def self.most_followed_questions(n)
        questions_rank = QuestionsDatabase.instance.execute(<<-SQL, n)
            SELECT 
                * 
            FROM 
                questions
            JOIN question_follows ON question_follows.question_id = questions.id
            GROUP BY question_follows.question_id
            ORDER BY COUNT(question_follows.user_id) DESC LIMIT ?
        SQL
        return nil unless questions_rank.length > 0 
        questions_rank.map { |question| Question.new(question) }
    end 

    def initialize(options)
        @id, @user_id, @question_id = options['id'], options['user_id'], options['question_id']
    end 
end