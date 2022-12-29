# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupEvent, type: :model do
  let(:user) { create(:user) }
  let(:group_event) { build(:group_event, user: user) }

  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    context 'enum validator' do
      it { should define_enum_for(:status).with_values(published: 1, draft: 0) }
    end

    context 'status' do
      it {
        is_expected.to validate_inclusion_of(:status)
          .in_array(%w[published draft])
          .with_message('invalid status')
      }
    end

    context 'validates duration to run on whole number of days' do
      it 'reutrn success when duration is integer and greater than 0' do
        group_event.duration = 1

        expect(group_event.valid?).to equal(true)
      end

      it 'return error when duration is in string' do
        group_event.duration = 'sds'
        group_event.end_on = nil

        expect(group_event.valid?).to equal(false)
        expect(group_event.errors.messages.values.flatten)
          .to include('is not a number')
      end

      it 'return error when duration is less than or equal to zero' do
        group_event.duration = -1
        group_event.end_on = nil

        expect(group_event.valid?).to equal(false)
        expect(group_event.errors.messages.values.flatten)
          .to include('must be greater than 0')

        group_event.duration = 0

        expect(group_event.valid?).to equal(false)
        expect(group_event.errors.messages.values.flatten)
          .to include('must be greater than 0')
      end

      it 'return error when duration is a decimal value' do
        group_event.end_on = nil
        group_event.duration = 1.5

        expect(group_event.valid?).to equal(false)
        expect(group_event.errors.messages.values.flatten)
          .to include('must be an integer')
      end
    end

    context 'start_on field validator' do
      it 'return error if date is less then today' do
        group_event.start_on = Date.today - 1

        expect(group_event.valid?).to equal(false)
        expect(group_event.errors.messages.values.flatten)
          .to include("must be on or after #{Date.today} 00:00:00")
      end

      it 'return success if date is equal or greater than today' do
        group_event.start_on = Date.today

        expect(group_event.valid?).to equal(true)

        group_event.start_on = Date.today + 1
        expect(group_event.valid?).to equal(true)
      end
    end

    context 'end_on field validator' do
      it 'return error if date is less than start_on' do
        group_event.end_on = group_event.start_on

        expect(group_event.valid?).to equal(false)
        expect(group_event.errors.messages.values.flatten)
          .to include("must be after #{group_event.start_on} 00:00:00")
      end

      it 'return success if date is equal or greater than start_on' do
        group_event.end_on = group_event.start_on + 1

        expect(group_event.valid?).to equal(true)
      end
    end

    context 'user presence check' do
      it { should validate_presence_of(:user_id) }
    end
  end

  describe '#description_formatting' do
    it 'convert formatted text to html format' do
      group_event.description = 'h3. This is description'
      group_event.save

      expect(group_event.description).to eq('<h3>This is description</h3>')
    end
  end

  describe '#set_time_attributes' do
    it 'set duration if start_on and end_on date fields present' do
      group_event.save

      expect(group_event.duration)
        .to eq((group_event.end_on - group_event.start_on).to_i)
    end

    it 'set end date if start and duration fields present' do
      group_event.save

      expect(group_event.end_on)
        .to eq(group_event.start_on + group_event.duration)
    end

    it 'set start date if duration and end_on fields present' do
      group_event.save

      expect(group_event.start_on)
        .to eq(group_event.end_on - group_event.duration)
    end
  end

  describe 'published the group event' do
    it 'return error if any of fields is not present' do
      group_event.description = nil
      group_event.status = 'published'
      group_event.save

      expect(group_event.errors.messages.values.flatten)
        .to include('to publish all of the fields are required')
    end

    it 'return success if all the fields are present' do
      group_event.status = 'published'
      group_event.save

      expect(group_event.status).to eq('published')
    end
  end

  describe 'draft the group event' do
    it 'return error if any of fields is not present' do
      ge = user.group_events.build

      expect(ge.save).to eq(false)
    end

    it 'return success if all of fields is present' do
      group_event.description = nil
      group_event.status = 'draft'

      expect(group_event.save).to eq(true)
      expect(group_event.status).to eq('draft')
    end
  end
end
