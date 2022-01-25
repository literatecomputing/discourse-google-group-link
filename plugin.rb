# frozen_string_literal: true

# name: discourse-google-groups-link
# about: TODO
# version: 0.0.1
# authors: pfaffman
# url: https://github.com/literatecomputing/discourse-google-group-link
# required_version: 2.7.0
# transpile_js: true

enabled_site_setting :plugin_name_enabled
GOOGLE_GROUP_LINK = 'google-group-link'

after_initialize do
  register_category_custom_field_type("mirrors_google_group", :boolean)
  register_topic_custom_field_type("google_group_link", :string)

  add_to_serializer(:topic_view, :google_group_link) do
    next unless self.topic.custom_fields[GOOGLE_GROUP_LINK]
    value = self.topic.custom_fields[GOOGLE_GROUP_LINK]  # get value from custom field
  end

  add_to_class(:topic, :add_google_group_link) do
    topic = self
    return if self.custom_fields[GOOGLE_GROUP_LINK]
    p = Post.find_by(topic_id: topic.id, post_number: 1)
    return unless p.raw_email
    m = /To view this discussion on the web visit <a href=3D"(.*?)"/m.match(p.raw_email)
    n = /To view this discussion on the web visit (https:\/\/groups.google.com\/.*?gmail.com)\./m.match(p.raw_email)
    o = /To view this discussion on the web visit (https:\/\/groups.google.com\/.*?googlegroups.com)\./m.match(p.raw_email)
    return unless m || n || o
    link = (m || n || o)[1]
    link = link.gsub("=\n", "")
    self.custom_fields[GOOGLE_GROUP_LINK] = link
    rescue => e
      Rails.logger.warn("Google link: add_google_group_link #{topic.title} failed with #{e}")
  end

  add_model_callback(:topic, :after_create_commit) do
    t = self
    Rails.logger.warn("Google link: callback #{t.title} was called" with cat #{t.category_id})
    category = Category.find(t.category_id)
    return unless category
    return unless category.mailinglist_mirror
    Rails.logger.warn("Google link: processing #{t.title}")
    t.add_google_group_link
    rescue => e
      Rails.logger.warn("Google link: callback #{t.title} failed with #{e}")
  end

  add_to_class(:topic, :google_group_link_ensure_consistency) do
    fix_these_topics = Topic.where(category_id: 5)
    fix_these_topics.each do |t|
      t.add_google_group_link
        t.save
    end
  end
end
