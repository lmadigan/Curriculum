require_relative 'questions_db'
require_relative 'question_follows'
require_relative 'questions'
require_relative 'replies'
require_relative 'users'

class QuestionLike
  attr_accessor :user_id, :question_id

  def initialize(options)
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end
