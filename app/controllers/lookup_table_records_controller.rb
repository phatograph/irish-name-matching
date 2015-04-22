class LookupTableRecordsController < ApplicationController
  def index
    @records = LookupTableRecord.all.order(:name)
  end

  def new
    @record = LookupTableRecord.new
  end

  def create
    @record = LookupTableRecord.new(permitted_params)
    @record.name = @record.name.upcase

    if @record.save
      redirect_to lookup_table_records_path
    else
      render 'new'
    end
  end

  def destroy
    record = LookupTableRecord.find(params[:id])
    record.destroy
    redirect_to :back
  end

  private

    def permitted_params
      params.require(:lookup_table_record).permit(
        :name,
        :ref
      )
    end
end
