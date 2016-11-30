require_relative 'questions_db'
require_relative 'question_likes'
require_relative 'questions'
require_relative 'replies'
require_relative 'users'
require 'byebug'

class QuestionFollow
  attr_accessor :user_id, :question_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.followers_for_question_id(question_id)
    users = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN
        question_follows ON question_follows.user_id = users.id
      JOIN
        questions ON question_follows.question_id = questions.id
      WHERE
        questions.id = ?
      SQL
    return nil unless users.length > 0
    users.map { |user| User.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    questions = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN
        question_follows ON question_follows.question_id = questions.id
      JOIN
        users ON question_follows.user_id = users.id
      WHERE
        users.id = ?
      SQL
    return nil unless questions.length > 0
    questions.map { |q| Question.new(q) }
  end

  def self.most_followed_questions(n)
    questions = QuestionsDatabase.instance.execute(<<-SQL, limit: n)
    SELECT
      questions.*
    FROM
      questions
    JOIN
      question_follows ON question_follows.question_id = questions.id
    JOIN
      users ON question_follows.user_id = users.id
    GROUP BY
      question_follows.question_id
    ORDER BY
      COUNT(question_follows.user_id) DESC
    LIMIT
      :limit
    SQL
    return nil unless questions.length > 0
    questions.map { |question| Question.new(question) }
  end

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @user_id, @question_id)
      INSERT INTO
        question_follows (user_id, question_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

end
