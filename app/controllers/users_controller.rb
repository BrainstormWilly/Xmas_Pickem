require 'twilio-ruby'

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    if @user.giftee!=0
      render :resend
    else
      render :show
    end
  end

  def update
    @user = User.find(params[:id])
    phone = params[:user][:phone]
    matches = User.where(phone:phone).where.not(id:@user.id)
    if matches.count > 0
      flash[:alert] = "That phone # is already taken. Surely you have a cell phone of your own. Cut it out, Damien!"
      redirect_to root_path
    elsif Phonelib.valid? "1#{phone}"
      @user.phone = phone
      if @user.giftee!=0
        @giftee = User.find(@user.giftee)
      else
        @giftee = User.where(giftor:0).where.not(id:@user.id).all.shuffle.first
        @giftee.giftor = @user.id
        @user.giftee = @giftee.id
      end
      if @user.save && @giftee.save
        client = Twilio::REST::Client.new ENV['YNO_TWILIO_SID'], ENV['YNO_TWILIO_TOKEN']
        client.messages.create(
          from: "+#{ENV['YNO_TWILIO_NUMBER']}",
          to: "+1#{@user.phone}",
          body: "#{@user.name}, your giftee is #{@giftee.name}"
        )
        render :send_success
      else
        flash.now[:alert] = "Oops, sorry. Something went wrong. Try again later?"
        render :show
      end
    else
      flash.now[:alert] = "Ah, that is not a phone #. Maybe go sober up for bit and try again later"
      render :show
    end
  end


  private

  def update_user_params
    params.require(:user).permit(:phone)
  end

end
