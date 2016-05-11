class EntriesController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user,   only: [:edit, :destroy, :toggle_scanned]
  before_action :admin_user,     only: :download_and_delete

  include EntriesHelper

  def index
    split_entries
    @entry = current_user.entries.build if logged_in?

    respond_to do |format|
      format.html
      format.js
      format.csv { render text: Entry.all.to_csv, content_type: 'text/plain' }
      # format.xls # { send_data @products.to_csv(col_sep: "\t") }
    end
  end

  def create
    @entry = current_user.entries.build(entry_params)
    if @entry.save
      flash[:success] = "Sample added to the queue!"
      redirect_to request.referrer || root_url
    else
      flash[:danger] = "Please fill out all the required fields."
      redirect_to request.referrer
    end
  end

  def edit
    @entry = Entry.find(params[:id])
  end

  def update
    @entry = Entry.find(params[:id])
    @entry.update(entry_params)
    flash[:success] = "Entry successfully updated."
    redirect_to entry_path(@entry)
  end

  def show
    @entry = Entry.find(params[:id])
  end

  def toggle_scanned
    @entry = Entry.find(params[:id])
    @entry.toggle!(:scanned)
    flash[:success] = "Sample scanned and archived" if @entry.scanned
    redirect_to request.referrer || root_url
  end

  def edit
    @entry = Entry.find(params[:id])
  end

  def destroy
    @entry = Entry.find(params[:id])
    @entry.destroy
    flash[:success] = "Sample deleted"
    redirect_to request.referrer || root_url
  end

  def scan
    @entry = Entry.find(params[:id])
    @entry.toggle!(:scanned)
    flash[:success] = "Sample scanned and archived"
    redirect_to request.referrer || root_url
  end

  def download
    time = Time.now.strftime "%Y-%m-%d %H:%M"
    filename = "XRD Export #{time}.csv"
    send_data Entry.all.to_csv, filename: filename
  end

  def download_and_delete
    download
    Entry.where(:scanned => true).delete_all
  end

  private

    def entry_params
      params.require(:entry).permit(:sample, :charge, :need_by, :file_format, :scan_type, :description, :instructions, :conditions)
    end

    def correct_user
      unless current_user.admin?
        @entry = current_user.entries.find_by(id: params[:id])
        if @entry.nil?
          flash[:danger] = "This sample does not belong to you."
          redirect_to root_url
        end
      end
    end

end
