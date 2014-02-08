enable :sessions
include BCrypt

get '/' do
  erb :index
end

post '/users' do
  # User.create(params)

  def create
    p params
    @user = User.new(params)
    @user.password=(params[:password])
    @user.save!
    session[:message] = "You just created yourself a user!"
  end

  create
  redirect '/'
end

post '/sessions' do
  def login
    @user = User.find_by_username(params[:username])
    if @user.password == params[:password]
      session[:logged_in] = true
      session[:message] = "You're signed in"
      session[:id] = @user.id
      # redirect to the "view all surveys" page
    else
      session[:message] = "Your password and/or username was wrong."
      redirect '/#{@user.id}/surveys'
    end
  end
  login
end

delete '/sessions' do
  session[:logged_in] = false
  session[:id] = nil
  session[:message] = nil
  erb :index
end

get '/:user_id/surveys'
  user = User.find(params[:user_id])
  @surveys = user.surveys
  erb :all_surveys
end