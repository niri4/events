#app/models/group_event.rb

#  - Group Events attributes {
#   start_on: date,
#   end_on: date,
#   duration: integer,
#   name: string,
#   description: text,
#   location: string,
#   deleted: boolean,
#   status: integer,
#   user_id: integer
# }

class GroupEvent < ApplicationRecord
  BASE_ATTRIBUTES = %i[start_on end_on duration name description location status].freeze
  enum status: { draft: 0, published: 1 }

  # - act as peranoid gem use to soft delete the record
  # - gem use the deleted column have boolean value
  # - if record have deleted value true then record soft deleted else its not
  # - Read more on https://github.com/ActsAsParanoid/acts_as_paranoid

  acts_as_paranoid(column: 'deleted', column_type: 'boolean')

  # - Association to user as user have many group events

  belongs_to :user

  # - Validations

  validate :any_base_attribute_present?, if: -> { status == 'draft' }
  validate :all_base_attributes_present?, if: -> { status == 'published' }

  # - Validation to check in record has user_id or not

  validates :user_id, presence: true

  # - validates status field it should be draft or published

  validates :status, inclusion: {
    in: statuses.keys,
    message: 'invalid status'
  }

  # - Overwrite the setter to rely on validations instead of [ArgumentError]
  # - not a better approch
  # - need to find good solution to work with inclusion and enum

  def status=(value)
    self[:status] = value
  rescue ArgumentError => e
    self[:status] = nil
  end

  # - validates duration field it should be whole number
  # - ( not decimal, not negative value and greter than 0)

  validates :duration, numericality: {
    only_integer: true, greater_than: 0
  }, allow_blank: true

  # - Validates start_on field it should not have previous date from today
  # - start_on date should not be less than Date.today
  # - Use gem validates_timeliness for timeliness
  # - Read more about https://github.com/adzap/validates_timeliness

  validates :start_on, timeliness: {
    on_or_after: Date.today
  }, allow_blank: true

  # - validates end_on field it should not have date which is less than
  # - end_on date should not be less than start_on
  # - Use gem validates_timeliness for timeliness
  # - Read more about https://github.com/adzap/validates_timeliness

  validates :end_on, timeliness: {
    after: :start_on
  }, allow_blank: true

  # - Callback to convert descrition
  # - String into html-format on description

  before_validation :description_formatting, if: -> { description.present? }

  # - Callback to check and set attributes start_on, end_on, duration
  # - If any two of fields are present

  before_validation :set_time_attributes

  private
  # - set description formatting to html
  # - formatting supports syntax are handle by RedCloth
  # - formatter styling follow
  # - https://www.promptworks.com/textile/
  # - see more on http://redcloth.org/
  # - for gem link https://github.com/jgarber/redcloth
  # - for  emojis we use EmojiParser which is part of gemoji-parser gem
  # - Read more on https://github.com/gmac/gemoji-parser
  # - For example follwing is the input "This is first para\r\n\r\nThis is second para"
  # - output is like "<p>This in first para</p><p>This is second para</p>"

  def description_formatting
    description = EmojiParser.detokenize(self.description)
    paragraphs = split_paragraphs(description).map(&:html_safe)
    html = ''
     paragraphs.each do |paragraph|
       html << textilize(paragraph)
     end
    self.description = html
  end

  # - Make array of paragraphs which need to be formatted
  # - For example follwing is the input "This is first para\r\n\r\nThis is second para"
  # - output is like ['This in first para',  'This is second para']

  def split_paragraphs(text)
    return [] if text.blank?
     text.to_str.gsub(/\r\n?/, "\n").split(/\n\n+/).map! do |t|
       t.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />') || t
     end
  end

  # - Check and set attributes start_on, end_on, duration
  # - If any two of fields are present

  def set_time_attributes
    self.start_on = (end_on - duration) if duration? && (end_on? && !start_on?)
    self.duration = (end_on - start_on).to_i if start_on? && (end_on? && !duration?)
    self.end_on = (start_on + duration) if start_on? && (duration? && !end_on?)
  end

  # - validates whether any base attributes are present
  # - In case of saving a event as draft
  # - Add errors if all fields are not present

  def any_base_attribute_present?
    unless BASE_ATTRIBUTES.any? { |attribute| self.send("#{attribute}?")}
      self.errors.add :base, 'specify at least one base attribute'
    end
  end

  # - Validates whether all the base attributes are present
  # - In case of saving a event as published
  # - Add errors if all fields are not present

  def all_base_attributes_present?
    unless BASE_ATTRIBUTES.all? { |attribute| self.send("#{attribute}?") }
      self.errors.add :base, 'to publish all of the fields are required'
    end
  end
end
