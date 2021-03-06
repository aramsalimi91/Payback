class StaticController < ApplicationController
  before_filter :must_be_logged_in, only: [:contact]

  def main
    return redirect_to expenses_path if signed_in?
  end

  def cash
  end

  def contact
    @message = Message.new
  end

  def mail
    @message = Message.new(params[:message])

    if @message.valid?
      Notifier.delay.new_message(@message)
      flash[:success] = "Thanks! We'll get back to you as soon as possible."
    else
      flash[:error] = "Please check your fields and try again!"
    end

    return redirect_to contact_path
  end

  def not_found
  end
end
