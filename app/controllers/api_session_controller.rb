class ApiSessionController < ApplicationController

  def create
    @user = User.find_by_login(params[:login])

    respond_to do |format|
      if @user == nil || @user.valid_password?(params[:password]) == false
        format.html # create.html.erb
        format.json { render json: "error" }
      else
        @user.newtoken
        format.html # create.html.erb
        format.json { render json: @user.authentication_token }
      end
    end
  end

  def destroy
    @user = User.find_by_authentication_token(params[:api_token])
    @user.authentication_token = nil
    @user.save
    respond_to do |format|
        format.html # create.html.erb
        format.json { render json: "token erased" }
    end
  end
end
  
