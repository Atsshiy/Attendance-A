class UsersController < ApplicationController
  before_action :set_user, only: %i(show edit update destroy edit_basic_info update_basic_info)
  before_action :logged_in_user, only: %i(index edit update destroy edit_basic_info update_basic_info)
  before_action :correct_user, only: %i(edit update)
  before_action :not_correct_user, only: %i(show)
  before_action :admin_user, only: %i(index working_list destroy edit_basic_info update_basic_info)
  before_action :not_admin_user, only: %i(show)
  before_action :set_one_month, only: %i(show)
  
  def index
    @users = User.paginate(page: params[:page],per_page:10)
    if params[:search].present?
      @users = User.paginate(page: params[:page]).search(params[:search]) 
    end
    unless current_user?(@user) || current_user.admin?
      flash[:danger] = "閲覧権限がありません。"
      redirect_to(root_url)
    end
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    @overtime = Attendance.where(overtime_status: "申請中",indicater_check: @user.name).count
    @change = Attendance.where(change_status: "申請中",indicater_check_edit: @user.name).count
    @month = Attendance.where(monthly_confirmation_status: "申請中",indicater_check_month: @user.name).count
    @superior = User.superior_users_without_me
    @attendance = @user.attendances.find_by(worked_on: @first_day)
    #CSV出力
    respond_to do |format|
      format.html
      filename = @user.name + ":" + l(@first_day, format: :middle) + "分の勤怠"
      format.csv {send_data render_to_string, type: 'text/csv; charset=shift_jis',filename: "#{filename}.csv"}
    end
  end

  def new
    if logged_in? && !current_user.admin?
      flash[:info] = 'すでにログインしています。'
      redirect_to current_user
    end
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end
  
  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def import
    if params[:csv_file].blank?
      flash[:warning] = "ファイルが選択されてません"
    else
      User.import(params[:csv_file])
      flash[:success] = "ユーザー情報をインポートしました。"
    end
    redirect_to users_url
  end
  
  def working_list
    @working_users = User.working_users
  end 
  
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid, :designated_work_end_time, :designated_work_start_time, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:affiliation, :basic_work_time, :work_time)
    end
end
