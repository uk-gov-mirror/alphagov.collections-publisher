class CoronavirusLandingPageController < ApplicationController

  def publish
    Services.publishing_api.put_content("774cee22-d896-44c1-a611-e3109cce8eae", payload)
  end

private

  def update_type
    params[:update_type]
  end

  def payload
    {
      "base_path": "/coronavirus",
      "content_id": "774cee22-d896-44c1-a611-e3109cce8eae",
      "document_type": "coronavirus_landing_page",
      "description": "Find out about the government response to coronavirus (COVID-19) and what you need to do.",
      "phase": "live",
      "publishing_app": "collections-publisher",
      "rendering_app": "collections",
      "schema_name": "coronavirus_landing_page",
      "title": "Coronavirus (COVID-19): what you need to do",
      "locale": "en",
      "updated_at": "2020-03-25T14:40:22Z",
      "links": {},
      "update_type": update_type,
      "details": details
    }
  end

  def details
    fetch_from_repo_and_parse["content"]
  end

  def fetch_from_repo_and_parse
    File.open("../../coronavirus.yml") { |file| YAML.load(file) }
  end

end
