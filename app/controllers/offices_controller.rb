class OfficesController < ApplicationController
  before_action :set_office, only: %i(edit update destroy)
  before_action :logged_in_user, only: %i(index edit update destroy)
  before_action :admin_user, only: %i(index new edit destroy)
  
  def index
    @offices = Office.paginate(page: params[:page],per_page:10)
  end
  
  def new
    @office = Office.new
  end
  
  def create
    @office = Office.new(office_params)
    if @office.save
      flash[:success] = '拠点情報を追加しました。'
    else
      flash[:danger] = '拠点情報の追加に失敗しました。'
    end
    redirect_to offices_url
  end
  
  def edit
  end
  
  def update
    if @office.update_attributes(office_params)
      flash[:success] = "#{@office.office_name}の拠点情報を更新しました。"
    else
      flash[:danger] = "#{@office.office_name}の拠点情報の更新に失敗しました。"
    end
    redirect_to offices_url
  end
  
  def destroy
    @office.destroy
    flash[:success] = "#{@office.office_name}のデータを削除しました。"
    redirect_to offices_url
  end
  
  private
  
    def set_office
      @office = Office.find(params[:id])
    end
    
    def office_params
      params.require(:office).permit(:office_name, :office_number, :office_category)
    end
end
