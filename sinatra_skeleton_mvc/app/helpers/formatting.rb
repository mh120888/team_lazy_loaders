helpers do
  include BCrypt

  def current_user 
    User.find(session[:id]) if session[:logged_in]
  end

  def set_user_survey
    @id = params[:id] if params[:id]
    @survey = Survey.find(params[:survey_id ]) if params[:survey_id]
  end 
############################################################### used for finding current user and survey
  def count_choices(params)
    params.select {|key| key.match(/\d/) != nil}.each do |question, answer|
      question = Question.find(question.to_i)
      choice = question.choices.where(text: answer).first 
      new_count = choice.count + 1
      choice.update_attributes(count: new_count)
      question.choices.each {|choice| update_choice_percentage(question, choice)} 
    end
  end

  def update_choice_percentage(question, choice)
    total_responses = question.choices.select("count").map {|choice| choice.count}.inject(:+)
    new_percentage = (choice.count.to_f / total_responses) * 100
    choice.update_attributes(percentage: new_percentage)
  end

  def params_parser(params)
    survey = Survey.create(name: params[:title], user_id: session[:id]) 
    counter = 0
    parse_questions(get_parameter(params, "question"), survey)
  end
############################################################################ used for parsing survey results and forms

def validate_survey(params)
  questions = Survey.find(params[:survey_id]).questions.select("text").map { |question| question.text}
  correct_length = questions.length + 4
  params.length == correct_length
end

def find_unanswered_questions(params)
  questions = Survey.find(params[:survey_id]).questions.select("id").map { |question| question.id}.map {|x| Question.find(x.to_i).text}
  questions_answered = params.keys[0..-5].map {|x| Question.find(x.to_i).text}
  questions - questions_answered
end

############################################################################ used for validating survey taking

  private

  def get_parameter(params, matcher)
    params.select {|key| key.include?(matcher)}
  end

  def parse_questions(questions, container)
    counter = 0
    questions.each do |question|
      new_question = Question.create(text: question[1]) 
      container.questions << new_question 
      get_parameter(params, counter.to_s + 'choice').each do |choice|
        new_choice = Choice.create(text: choice[1]) 
        new_question.choices << new_choice 
      end
      counter += 1
    end
  end

  




end
