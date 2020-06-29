module CoronavirusPages
  class DraftUpdater
    DraftUpdaterError = Class.new(StandardError)

    attr_reader :coronavirus_page

    def initialize(coronavirus_page)
      @coronavirus_page = coronavirus_page
    end

    delegate :content_id, :base_path, to: :coronavirus_page

    def content_builder
      @content_builder ||= CoronavirusPages::ContentBuilder.new(coronavirus_page)
    end

    def payload
      if content_builder.success?
        CoronavirusPagePresenter.new(content_builder.data, base_path)
      else
        raise DraftUpdaterError, content_builder.errors.to_sentence
      end
    end

    def send
      @send ||= Services.publishing_api.put_content(content_id, payload)
    rescue GdsApi::HTTPServerError
      # TODO: Send to sentry
      errors << "Failed to update the draft content item - please try saving again"
      false
    rescue GdsApi::HTTPUnprocessableEntity, DraftUpdaterError => e
      # TODO: Send to sentry
      errors << e.message
      false
    end

    def errors
      @errors ||= []
    end
  end
end
