class ImportItem < ApplicationRecord
  serialize :details, Hash
  belongs_to :import

  attr_accessor :alt

  after_commit :import_feed, on: :create

  enum status: [:pending, :complete, :failed]

  def import_feed
    if alt

    else
      FeedImporter.perform_async(id)
    end
  end
end
