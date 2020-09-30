class AnnouncementsController < ApplicationController
  before_action :require_unreleased_feature_permissions!
  layout "admin_layout"

  def new
    @coronavirus_page = CoronavirusPage.find_by(slug: params[:coronavirus_page_slug])
    @announcement = @coronavirus_page.announcements.new
  end

  def create
    @coronavirus_page = CoronavirusPage.find_by(slug: params[:coronavirus_page_slug])

    @announcement = @coronavirus_page.announcements.new(announcement_params)
    if @announcement.save

      redirect_to coronavirus_page_path(@coronavirus_page.slug), notice: "Announcement was successfully created."
    else
      render :new
    end
  end

  def edit
    @coronavirus_page = CoronavirusPage.find_by(slug: params[:coronavirus_page_slug])
    @announcement = @coronavirus_page.announcements.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])
    @coronavirus_page = @announcement.coronavirus_page
    if @announcement.update(announcement_params)
      redirect_to coronavirus_page_path(@coronavirus_page.slug), notice: "Announcement was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @announcement = Announcement.find(params[:id])
    @coronavirus_page = @announcement.coronavirus_page
    message = if @announcement.delete
                { notice: "Announcement was successfully deleted." }
              else
                { alert: "Announcement couldn't be deleted" }
              end
    redirect_to coronavirus_page_path(@coronavirus_page.slug), message
  end

private

  def announcement_params
    params.require(:announcement).permit(:text, :href, :published_at).merge(format_published_at)
  end

  def format_published_at
    unless params["announcement"]["published_at"].values.any?(&:empty?)
      begin
        format_date = { published_at: Time.zone.local(
          params["announcement"]["published_at"]["year"],
          params["announcement"]["published_at"]["month"],
          params["announcement"]["published_at"]["day"],
        ) }
        format_date
      rescue ArgumentError => e
        Rails.logger.info "Rescued: #{e.inspect}"
      end
    end
  end
end