# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20210411125743) do

  create_table "Attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "overtime_status"
    t.string "instructor_confirmation"
    t.string "business_process_content"
    t.datetime "scheduled_end_time"
    t.boolean "next_day"
    t.boolean "monthly_confirmation_change"
    t.string "application"
    t.datetime "changed_started_at"
    t.datetime "changed_finished_at"
    t.integer "monthly_confirmation_status"
    t.boolean "notice_overtime_change"
    t.integer "overtime_approval"
    t.string "overtime_check"
    t.integer "overtime_superior_id"
    t.integer "change_superior_id"
    t.integer "change_status"
    t.boolean "change_check"
    t.integer "change_approval"
    t.boolean "change_next_day_check"
    t.integer "monthly_approval"
    t.datetime "monthly_apply"
    t.date "calendar"
    t.string "overtime_hours"
    t.integer "superior_id"
    t.string "superior_name"
    t.string "change_superior_name"
    t.datetime "approval_date"
    t.string "indicater_check"
    t.datetime "before_started_at"
    t.datetime "before_finished_at"
    t.boolean "tomorrow"
    t.string "indicater_check_edit"
    t.string "indicater_check_month"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "Users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.time "basic_work_time", default: "2000-01-01 23:00:00"
    t.datetime "work_time", default: "2021-04-10 22:30:00"
    t.datetime "designated_work_start_time"
    t.datetime "designated_work_end_time"
    t.boolean "superior"
    t.integer "employee_number"
    t.string "affiliation"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "offices", force: :cascade do |t|
    t.integer "office_number"
    t.string "office_name"
    t.string "office_category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
