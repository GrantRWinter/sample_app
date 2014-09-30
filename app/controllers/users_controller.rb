class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user, only: :destroy
  before_action :signed_in_user_filter, only: [:new, :create]
  #webhook comment
  def show
    @user = User.find(params[:id])
    #just like User.find(1)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Settings updated successfully"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    user = User.find(params[:id])
    unless current_user?(user)  
      user.destroy
      flash[:success] = "User deleted."
    end
    redirect_to users_url
  end

  def index 
    @users = User.paginate(page: params[:page])
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # Before filters

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_url, notice: "Please sign in."
      end
    end

    #the above is short for 

    # def signed_in_user
    #   unless signed_in?
    #     flash[:notice] = "Please sign in."
    #     redirect_to signin_url
    #   end
    # end


    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

    def signed_in_user_filter
      redirect_to root_url, notice: "You are already signed in" if signed_in?

    end
end
