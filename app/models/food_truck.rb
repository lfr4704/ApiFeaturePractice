class FoodTruck < ApplicationRecord
  has_many :tags
  accepts_nested_attributes_for :tags

  validates :name, presence: true

  scope :tagged_with, -> (tag) { joins(:tags).where(tags: { id: tag.id }) }

  def to_h
    {
      id: id,
      created_at: created_at.to_formatted_s(:iso8601),
      updated_at: updated_at.to_formatted_s(:iso8601),
      name: name.force_encoding("utf-8"),
      description: description&.force_encoding("utf-8"),
      hours: hours,
      tags: tags.pluck(:name)
    }
  end

  def set_location(latitude:, longitude:)
    # TODO: Implement or alias this method to use your chosen persistence scheme
  end

  # Public: Get the schedule for this food truck. Assumes all
  # trucks open and close at the same time any day they are
  # open.
  #
  # Examples
  #
  #   truck.hours
  #   # => { :monday => "10 AM - 5 PM", :tuesday => "10 AM - 5 PM", :wednesday => nil, ... }
  #
  # Returns a Hash
  def hours
    formatted_hours = [opens_at, closes_at].map do |time|
      time.respond_to?(:strftime) ? time.strftime("%I %p") : "?"
    end.join(" - ")

    {}.tap do |h|
      Date::DAYNAMES.map(&:downcase).each do |day|
        h[:"#{day}"] = self["open_#{day}"] ? formatted_hours : nil
      end
    end
  end

  private

  def opens_at
    return unless opens_at_hour?

    Time.parse("#{opens_at_hour}:00")
  end

  def closes_at
    return unless closes_at_hour?

    Time.parse("#{closes_at_hour}:00")
  end
end
