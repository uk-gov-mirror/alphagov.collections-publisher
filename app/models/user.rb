# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  email                   :string(255)
#  uid                     :string(255)      not null
#  organisation_slug       :string(255)
#  permissions             :string(255)
#  remotely_signed_out     :boolean          default(FALSE)
#  disabled                :boolean          default(FALSE)
#  organisation_content_id :string(255)
#
# Indexes
#
#  index_users_on_uid  (uid) UNIQUE
#

class User < ActiveRecord::Base
  include GDS::SSO::User

  serialize :permissions, Array
end
