# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::GroupEventsController, type: :request do
  let(:user) { create(:user) }
  let(:group_event) { create(:group_event, user: user) }
  let(:group_events) { create_list(:group_event, 10, user: user) }

  describe 'GET #index' do
    before do
      group_events
    end

    it 'returns all the group events' do
      get api_v1_group_events_path(format: :json)

      expect(JSON.parse(response.body)['data']).to eq(group_events.as_json)
      expect(JSON.parse(response.body)['data'].length).to eq(10)
      expect(response.status).to eq(200)
    end

    it 'returns draft gorup event when filter_by as draft selected' do
      get api_v1_group_events_path(filter_by: 'draft', format: :json)
      draft_group_events = group_events.map do |event|
        event if event.status == 'draft'
      end

      expect(JSON.parse(response.body)['data'].length)
        .to eq(draft_group_events.compact.length)

      expect(JSON.parse(response.body)['data'])
        .to eq(draft_group_events.compact.as_json)

      expect(response.status).to eq(200)
    end

    it 'returns draft gorup event when filter_by as published selected' do
      get api_v1_group_events_path(filter_by: 'published', format: :json)
      published_group_events = group_events.map do |event|
        event if event.status == 'published'
      end

      expect(JSON.parse(response.body)['data'].length)
        .to eq(published_group_events.compact.length)

      expect(JSON.parse(response.body)['data'])
        .to eq(published_group_events.compact.as_json)

      expect(response.status).to eq(200)
    end
  end

  describe 'GET #show' do
    it 'retrieve a specific group event' do
      get api_v1_group_event_path(group_event.id, format: :json)

      expect(JSON.parse(response.body)['data']['name']).to eq(group_event.name)
      expect(response.status).to eq(200)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'create a new group event as a draft' do
        expect do
          post api_v1_group_events_path(
            format: :json,
            group_event: attributes_for(:group_event)
          )
        end.to change(GroupEvent, :count).by(1)

        expect(response.status).to eq(201)
      end

      it 'create a new group event as a published with all field' do
        group_event = attributes_for(:group_event)
        group_event[:status] = 'published'

        expect do
          post api_v1_group_events_path(
            format: :json,
            group_event: group_event
          )
        end.to change(GroupEvent, :count).by(1)
        expect(response.status).to eq(201)
      end
    end

    context 'with invalid attributes' do
      it "doesn't create a new group event" do
        group_event = { duration: 0 }

        expect do
          post api_v1_group_events_path(format: :json, group_event: group_event)
        end.to_not change(GroupEvent, :count)

        expect(response.status).to eq(422)
      end

      it "doesn't create a new published group event with subset of values" do
        group_event = { duration: 1, status: 'published', name: 'ge1' }

        expect do
          post api_v1_group_events_path(format: :json, group_event: group_event)
        end.to_not change(GroupEvent, :count)

        expect(JSON.parse(response.body)['error']['base'])
          .to include('to publish all of the fields are required')

        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid attributes' do
      it 'update group event attributes' do
        ge = {
          name: 'my updated group event'
        }

        put api_v1_group_event_path(
          id: group_event.id,
          format: :json,
          group_event: ge
        )
        group_event.reload

        expect(group_event.name).to eq(ge[:name])
        expect(response.status).to eq(202)
      end
    end

    context 'with invalid attributes' do
      it "doesn't update group event attributes" do
        ge = {
          name: 'my updated group event',
          duration: 1.2
        }
        put api_v1_group_event_path(
          id: group_event.id,
          format: :json,
          group_event: ge
        )
        group_event.reload

        expect(group_event.name).to_not eq(ge[:name])
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'mark the group event as deleted(soft deleted)' do
      delete api_v1_group_event_path(id: group_event.id, format: :json)
      group_event.reload

      expect(group_event.deleted).to be_truthy
      expect(response.status).to eq(200)
    end
  end
end
