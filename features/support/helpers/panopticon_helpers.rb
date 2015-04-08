module PanopticonHelpers
  def check_mainstream_browse_page_was_created_in_panopticon(tag_id:, title:, description: nil, parent_id: nil)
    expect(CollectionsPublisher.services(:panopticon)).to have_received(:create_tag)
      .with(hash_including(
        tag_type: 'section',
        tag_id: tag_id,
        title: title,
        description: description,
        parent_id: parent_id,
      ))
  end

  def check_mainstream_browse_page_was_updated_in_panopticon(tag_id:, title:, description: nil)
    expect(CollectionsPublisher.services(:panopticon)).to have_received(:put_tag)
      .with('section', tag_id, hash_including(
        tag_type: 'section',
        tag_id: tag_id,
        title: title,
        description: description,
      ))
  end

  def check_mainstream_browse_page_was_published_in_panopticon(tag_id:)
    expect(CollectionsPublisher.services(:panopticon)).to have_received(:publish_tag)
      .with('section', tag_id)
  end
end

World(PanopticonHelpers)