class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Account created successfully!"
      render :new
    else
      flash.now[:alert] = "Account creation failed!"
      render :new
    end
  end

  def login
    @user = User.new
  end

  def create_session
    @user = User.find_by(email: params[:email])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      flash[:notice] = "Logged in successfully!"
      redirect_to root_path
    else
      flash.now[:alert] = "Invalid email or password!"
      render :login
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out successfully!"
    redirect_to login_path
  end

  def profile
    @user = User.find(session[:user_id])
    life_bonus = 0
    strength_bonus = 0
    xp_bonus = 0.0
    @user.inventory.each do |key, item|
      if item["equipped"].to_s == "true"
        life_bonus += item["life"].to_i
        strength_bonus += item["strength"].to_i
        xp_bonus += item["xp_bonus"].to_f
      end
    end
    @bonuses = { life: life_bonus, strength: strength_bonus, xp: xp_bonus }
  end

  def add_life
    @user = User.find(session[:user_id])
    points = params[:points].to_i
    if @user.points >= points
      @user.update(life: @user.life + points, points: @user.points - points, used_points: @user.used_points + points)
      redirect_to profile_path
    else
      flash[:alert] = "You don't have enough points!"
      redirect_to profile_path
    end
  end

  def add_strength
    @user = User.find(session[:user_id])
    points = params[:points].to_i
    if @user.points >= points
      @user.update(strength: @user.strength + points, points: @user.points - points, used_points: @user.used_points + points)
      redirect_to profile_path
    else
      flash[:alert] = "You don't have enough points!"
      redirect_to profile_path
    end
  end

  def equip_item
    @user = User.find(session[:user_id])
    item_to_equip = @user.inventory[params[:item_id]]

    if item_to_equip
      already_equipped_item = @user.inventory.values.find { |item| item["type"] == item_to_equip["type"] && item["equipped"] == true }

      if already_equipped_item
        flash[:alert] = "You already have a #{item_to_equip["type"]} equipped!"
      else
        item_to_equip["equipped"] = true
        @user.save
        flash[:notice] = "#{item_to_equip["type"]} equipped!"
      end
    else
      flash[:alert] = "Item not found!"
    end

    redirect_to profile_path
  end

  def unequip_item
    @user = User.find(session[:user_id])
    item_to_unequip = @user.inventory[params[:item_id]]

    if item_to_unequip && item_to_unequip["equipped"] == true
      item_to_unequip["equipped"] = false
      @user.save
      flash[:notice] = "#{item_to_unequip["type"]} unequipped!"
    else
      flash[:alert] = "Item not found or not equipped!"
    end

    redirect_to profile_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end