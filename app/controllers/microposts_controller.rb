class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    param = micropost_params
    con = param[:content]
    if(con != "")
      if (con.include?("@"))
        index_at = con.index("@")+1
        index_space = con.index(" ",index_at)-1 || con.count
        reply = con.slice(index_at..index_space)
        reply_user = User.find_by(name: reply)
        if (!reply_user.nil?)
          param[:in_reply_to] = reply_user.id
        end
      end
    end
    @micropost = current_user.microposts.build(param)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture, :in_reply_to)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end