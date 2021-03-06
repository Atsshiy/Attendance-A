class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  $days_of_the_week = %w{日 月 火 水 木 金 土}
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def logged_in_user
    unless logged_in?
      flash[:danger]="ログインしてください"
      redirect_to login_url
    end
  end
  
  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    @user = User.find(params[:id])
    unless current_user?(@user)
      flash[:danger] = "他者のページは閲覧できません"
      redirect_to root_url
    end
  end
  
  def correct_user_b
    @user = User.find(params[:user_id])
    unless current_user?(@user)
      flash[:danger] = "他者のページは閲覧できません"
      redirect_to root_url
    end
  end
  
  def not_correct_user
    unless current_user == @user
      flash[:danger] = "他者のページは閲覧できません"
      redirect_to root_url
    end
  end
  
  # システム管理権限所有かどうか判定します。
  def admin_user
    unless current_user.admin?
      flash[:danger] = "ページ遷移の権限がありません"
      redirect_to(root_url)
    end
  end
  
  def not_admin_user
    if current_user.admin?
      flash[:danger] = "ページ遷移の権限がありません"
      redirect_to(root_url)
    end
  end
  
  def set_one_month 
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day]
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
  
    unless one_month.count == @attendances.count
      ActiveRecord::Base.transaction do
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
  
end
