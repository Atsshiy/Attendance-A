module AttendancesHelper
  
  def attendance_state(attendance)
    # 受け取ったAttendanceオブジェクトが当日と一致するか評価します。
    if Date.current == attendance.worked_on
      return '出勤' if attendance.started_at.nil?
      return '退勤' if attendance.started_at.present? && attendance.finished_at.nil?
    end
    # どれにも当てはまらなかった場合はfalseを返します。
    false
  end
  
  def time_select_invalid?(item)
    item[:change_superior_id].present? && item["started_at(4i)"] == "" && item["started_at(5i)"] == "" && item["finished_at(4i)"] == "" && item["finished_at(5i)"] == ""
  end
  
  #残業申請中の社員
  def overtime_apply_employee
    User.joins(:attendances).where.not(attendances: {overtime_superior_id: nil}).where(attendances: {overtime_approval: 2}).distinct
  end
  
  def overtime_worked(finish, end_time, nextday)
    #format("%.2f", (((finish - start) / 60) / 60.0))
    if nextday == true
      format("%.2f", (((finish.hour - end_time.hour) + ((finish.min - end_time.min) / 60.0) + 24)))
    else
      format("%.2f", (((finish.hour - end_time.hour) + ((finish.min - end_time.min) / 60.0))))
    end
  end
  
  #残業申請が自分にきているか
  def has_overtime_apply
    User.joins(:attendances).where(attendances: {overtime_superior_id: current_user.id}).where(attendances: {overtime_status: "申請中"})
  end
  
  #残業申請のステータス
  def overtime_status_text(status)
    case status
    when "申請中"
      "残業申請中"
    when "否認"
      "残業否認"
    when "承認"
      "残業承認"
    when "なし"
    else
    end
  end
  
  #勤怠変更申請の社員
  def change_apply_employee
    User.joins(:attendances).where.not(attendances: {change_superior_id: nil}).where(attendances: {overtime_approval: 2}).distinct
  end
  
  #勤怠変更申請が自分にきているか
  def has_change_apply
    User.joins(:attendances).where(attendances: {change_superior_id_id: current_user.id}).where(attendances: {change_status: "申請中"})
  end
  
  #勤怠変更申請のステータス
  def change_status_text(status)
    case status
    when "申請中"
      "勤怠変更申請中"
    when "否認"
      "勤怠変更否認"
    when "承認"
      "勤怠変更承認"
    else "なし"
    end
  end
  
  #1ヶ月勤怠申請が自分にきているか
  def has_month_apply
    User.joins(:attendances).where(attendances: {superior_id: current_user.id}).where(attendances: {change_status: "申請中"})
  end
  
  #勤怠申請の変更にチェックはあるか
  def checked_confirmed?(status, check)
    if (status == "承認" || status == "否認") && check == true
      confirmed = true
    else
      confirmed = false
    end
    confirmed
  end
  
  #1ヶ月勤怠申請の件数
  def month_apply_count
    User.joins(:attendances).where(attendances: {superior_id: current_user.id}).where(attendances: {monthly_confirmation_status: "申請中"})
  end
  
  #勤怠変更申請の件数
  def change_apply_count
    User.joins(:attendances).where(attendances: {change_superior_id: current_user.id}).where(attendances: {change_status: "申請中"})
  end
  
  #残業申請お知らせの件数
  def overtime_apply_count
    User.joins(:attendances).where(attendances: {overtime_superior_id: current_user.id}).where(attendances: {overtime_status: "申請中"})
  end
  
  #勤怠ログの上長
  def change_superior
    User.where(superior: true)
  end
  
end