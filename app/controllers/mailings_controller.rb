class MailingsController < ApplicationController
  def index
    redirect_to :action => :list
  end
  
  def overview
  end

  def list
    @mailings = Mailing.find(:all)
  end

  def statistics
  end
end
