class AttendancesController < ApplicationController
  before_action :set_user, only: %i(edit_one_month update_one_month update_month_approval edit_notice_overwork edit_one_month_notice edit_month_approval_notice)
  before_action :logged_in_user, only: %i(update edit_one_month)
  before_action :not_admin_user
  before_action :admin_or_correct_user, only: %i(update edit_one_month update_one_month)
  before_action :set_one_month, only: %i(edit_one_month)
  before_action :correct_user, only: %i(edit_one_month)
  before_action :correct_user_b, only: %i(log)
  
  UPDATE_ERROR_MSG = "エラーが発生しました。"

  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  #勤怠変更申請
  def edit_one_month
    @attendance = Attendance.find(params[:id])
    @superior = User.where(superior:true).where.not(id:current_user.id)
  end
  
  #勤怠変更申請更新
  def update_one_month
    ActiveRecord::Base.transaction do
      om_cnt = 0
      attendances_params.each do |id, item|
        @attendance = Attendance.find(id)
        # 上長が選択されているか？
        if item[:indicater_check].present?
          if item[:changed_started_at].blank? && item[:changed_finished_at].present?
            flash[:danger] = "出勤時刻がありません"
            redirect_to attendances_edit_one_month_user_url(date: params[:date])
            return
          elsif item[:changed_started_at].present? && item[:changed_finished_at].blank?
            flash[:danger] = "退勤時刻がありません"
            redirect_to attendances_edit_one_month_user_url(date: params[:date])
            return
          elsif item[:changed_started_at].blank? && item[:changed_finished_at].blank?
            flash[:danger] = "時刻を入力してください"
            redirect_to attendances_edit_one_month_user_url(date: params[:date])
            return
          elsif item[:changed_started_at].present? && item[:changed_finished_at].present? && item[:next_day] == false && item[:changed_started_at].to_s > item[:changed_finished_at].to_s
            flash[:danger] = "時刻に誤りがあります"
            redirect_to attendances_edit_one_month_user_url(date: params[:date])
            return
          elsif item[:note].blank?
            flash[:danger] = "変更内容を記入してください"
            redirect_to attendances_edit_one_month_user_url(date: params[:date])
            return
          end
          # カラム更新
          om_cnt += 1
          @attendance.update_attributes!(item)
        end
    end
    
    if om_cnt > 0
      flash[:success] = "勤怠変更を#{om_cnt}件受け付けました。"
      redirect_to user_url(@user)
    else
      flash[:danger] = "上長を選択してください"
      redirect_to attendances_edit_one_month_user_url(date: params[:date])
      return
    end
  end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
    return
  end
  
  #残業申請提出ページモーダル
  def edit_overwork_request
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    @superior = User.where(superior:true).where.not(id:current_user.id)
  end
  
  #残業申請提出ページモーダル更新
  def update_overwork_request
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.update_attributes(overwork_request_params)
      flash[:success] = "残業申請を受け付けました"
      redirect_to user_url(@user)
    end
  end
  
  #残業申請のお知らせモーダル
  def edit_notice_overwork
    @users = User.joins(:attendances).group("users_id").where(attendances: {overtime_status: "申請中"})
    @attendances = Attendance.where.not(scheduled_end_time: nil).order("worked_on ASC")
  end
  
  #残業申請のお知らせモーダル更新
  def update_notice_overwork
    ActiveRecord::Base.transaction do
      cnt1 = 0
      cnt2 = 0
      cnt3 = 0
      overwork_notice_params.each do |id,item|
        if item[:overtime_status].present?
          if(item[:change_check]) && (item[:change_status] == "なし" || item[:change_status] == "承認" || item[:change_status] == "否認")
            attendance = Attendance.find(id)
            if item[:change_status] == "なし"
              cnt1 += 1
              item[:scheduled_end_time] = nil
              item[:next_day] = nil
              item[:business_process_content] = nil
              item[:indicater_check] = nil
            elsif item[:change_status] == "承認"
              cnt2 += 1
              item[:indicater_check] = nil
            elsif item[:change_status] == "否認"
              cnt3 += 1
              item[:scheduled_end_time] = nil
              item[:next_day] = nil
              item[:business_process_content] = nil
              item[:indicater_check] = nil
            end
            attendance.update_attributes!(item)
          end
        else
          flash[:danger] = "指示者確認を更新、または変更にチェックを入れてください"
          redirect_to user_url(params[:user_id])
          return
        end
      end
      flash[:success] = "【残業申請】#{cnt1}件なし,#{cnt2}件承認,#{cnt3}件否認しました"
      redirect_to user_url(params[:user_id])
      return
    end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルされました。"
    redirect_to edit_notice_overwork_user_attendance_url(@user,item)
  end
  
  #勤怠変更申請のお知らせモーダル
  def edit_one_month_notice
    @users = User.joins(:attendances).group("users_id").where(attendances: {change_status: "申請中"})
    @attendances = Attendance.where.not(changed_started_at: nil, changed_finished_at: nil, note: nil, change_status: nil).order("worked_on ASC")
  end
  #勤怠変更申請のお知らせモーダル更新
  def update_one_month_notice
    ActiveRecord::Base.transaction do
      omn_cnt1 = 0
      omn_cnt2 = 0
      omn_cnt3 = 0
      attendances_notice_params.each do |id, item|
      if monthly_confirmation_status.present?
        if (item[:change_check]) && (item[:monthly_confirmation_status] == "なし" || item[:monthly_confirmation_status] == "承認" || item[:monthly_confirmation_status] == "否認")
          attendance = Attendance.find(id)
          if item[:monthly_confirmation_status] == "なし"
            omn_cnt1 += 1
            item[:changed_started_at] = nil
            item[:changed_finished_at] = nil
            item[:next_day] = nil
            item[:note] = nil
            item[:indicater_check] = nil
          elsif item[:monthly_confirmation_status] == "承認"
            if attendance.before_started_at.blank?
              item[:before_started_at] = attendance.started_at
            end
            if attendance.before_finished_at.blank?
              item[:before_finished_at] = attendance.finished_at
            end
            item[:started_at] = attendance.changed_started_at
            item[:finished_at] = attendance.changed_finished_at
            item[:indicater_check] = nil
            omn_cnt2 += 1
          elsif item[:monthly_confirmation_status] == "否認"
            item[:changed_started_at] = nil
            item[:changed_finished_at] = nil
            item[:next_day] = nil
            item[:note] = nil
            item[:indicater_check] = nil
            omn_cnt3 += 1
          end
          attendance.update_attributes!(item)
        end
      else
        flash[:danger] = "指示者確認を更新、または変更にチェックを入れてください"
        redirect_to user_url(params[:user_id])
        return
      end
    end
    flash[:success] = "【勤怠変更申請】#{omn_cnt1}件なし,#{omn_cnt2}件承認,#{omn_cnt3}件否認しました"
    redirect_to user_url(params[:user_id])
    return
  end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルされました。"
    redirect_to edit_one_month_notice_user_attendance_url(@user,item)
  end
  
  #1ヶ月勤怠承認
  def update_month_approval
    @attendance = @user.attendances.find_by(worked_on: params[:user][:monthly_approval])
    if month_request_params[:monthly_confirmation_status].present?
      @attendance.update_attributes(month_approval_params)
      flash[:success] = "勤怠承認申請を受け付けました"
    else
      flash[:danger] = "上長を選択してください"
    end
    redirect_to user_url(@user)
  end
  
  def edit_month_approval_notice
    @users = User.joins(:attendances).group("users_id").where(attendances: {monthly_confirmation_status: "申請中"})
    @attendances = Attendance.where.not(monthly_apply: nil, monthly_confirmation_status: nil).order("monthly_apply ASC")
  end
  
  #1ヶ月勤怠承認更新
  def update_month_approval_notice
    ActiveRecord::Base.transaction do
      man_cnt1 = 0
      man_cnt2 = 0
      man_cnt3 = 0
      month_approval_notice_params.each do |id, item|
      if item[:monthly_confirmation_status].present?
        if (item[:monthly_confirmation_change]) && (item[:monthly_confirmation_status] == "なし" || item[:monthly_confirmation_status] == "承認" || item[:monthly_confirmation_status] == "否認")
          attendance = Attendance.find(id)
          if item[:monthly_confirmation_status] == "なし"
            man_cnt1 += 1
            item[:monthly_apply] = nil
            item[:indicater_check] = nil
          elsif item[:monthly_confirmation_status] == "承認"
            man_cnt2 += 1
          elsif item[:monthly_confirmation_status] == "否認"
            man_cnt3 += 1
          end
          attendance.update_attributes!(item)
        else
          flash[:danger] = "指示者確認を更新、または変更にチェックを入れてください"
          redirect_to user_url(params[:user_id])
          return
        end
      end
    end
    flash[:success] = "【1ヶ月の承認申請】#{man_cnt1}件なし,#{man_cnt2}件承認,#{man_cnt3}件否認しました"
    redirect_to user_url(params[:user_id])
    return
  end
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルされました。"
    redirect_to edit_month_approval_notice_user_attendance_url(@user,item)
  end
 
  #勤怠ログ
  def log
    @user = User.find(params[:user_id])
    #1iは年、2iは月
    if params["worked_on(1i)"].present? && params["worked_on(2i)"].present?
      year_month = "#{params["worked_on(1i)"]}/#{params["worked_on(2i)"]}"
      @day = DateTime.parse(year_month) if year_month.present?
      @attendances = @user.attendances.where(change_status: "承認").where(worked_on: @day.all_month)
    else
      @attendances = @user.attendances.where(change_status: "承認").order("worked_on ASC")
    end
  end
  
  private
  
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :changed_started_at, :changed_finished_at, :next_day, :note, :indicater_check, :change_status])[:attendances]
    end
    
    # 勤怠編集お知らせモーダル
    def attendances_notice_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :before_started_at, :before_finished_at, :changed_started_at, :changed_finished_at, :note, :change_status, :change_check])[:attendances]
    end
    
    # 残業申請モーダルの情報
    def overwork_request_params
      #残業終了予定時間,翌日、残業内容、指示者確認（どの上長か）、指示者確認（申請かどうか）
       params.require(:attendance).permit(:scheduled_end_time, :tomorrow, :business_process_content, :overtime_check, :indicater_check, :overtime_status)
    end
    
    # 残業申請お知らせモーダルの情報
    def overwork_notice_params
       params.require(:user).permit(attendances: [:scheduled_end_time, :business_process_content, :overtime_status, :notice_overtime_change, :indicater_check])[:attendances]
    end
    
    
    # 1ヶ月の勤怠申請
    def month_approval_params
      params.require(:user).permit(attendances: [:monthly_confirmation_status, :monthly_apply, :indicater_check])
    end
    
    # 1ヶ月の勤怠申請モーダル
    def month_approval_notice_params
      params.require(:user).permit(attendances: [:monthly_confirmation_status, :monthly_confirmation_change, :monthly_apply, :indicater_check])[:attendances]
    end
end
