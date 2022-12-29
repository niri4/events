# frozen_string_literal: true

# app/controllers/api/v1/group_events_controller.rb

module Api
  module V1
    class GroupEventsController < ApplicationController
      before_action :find_group_event, except: %i[index create]

      # - API to get list of group events
      # - by default get all(published, draft) the list of group events
      # - GET api/v1/group_events.json
      # - parameter filtered_by present to get isolate group events
      # - GET /group_events.json?filtered_by=published
      # - GET /group_events.json?filtered_by=draft

      def index
        group_events = current_user.group_events

        case params[:filter_by]
        when 'published'
          group_events = group_events.published
        when 'draft'
          group_events = group_events.draft
        end

        render json: { data: group_events }, status: :ok
      end

      # - API to show a particular group events
      # - GET api/v1/group_events/:id.json

      def show
        render json: { data: @group_event }, status: :ok
      end

      # - API to create group events
      # - payload {
      # 	"group_event":{
      # 		"name": "lets go and rock",
      # 		"status": "published",
      # 		"description": "this is description",
      # 		"location": "gltssss",
      # 		"start_on": "2020/11/19",
      # 		"duration": "10"
      # 	}
      # }
      # - POST api/v1/group_events.json

      def create
        group_event = current_user.group_events.new(group_event_params)

        unless group_event.save
          render json: { error: group_event.errors }, status: :unprocessable_entity
          return
        end

        render json: { data: group_event }, status: :created
      end

      # - API to update group events
      # - Payload {
      # 	"group_event":{
      # 		"name": "lets go and rock",
      # 		"status": "published",
      # 		"description": "this is description",
      # 		"location": "gltssss",
      # 		"start_on": "2020/11/19",
      # 		"duration": "10"
      # 	}
      # }
      #  - PUT api/v1/group_events/:id.json

      def update
        @group_event.assign_attributes(group_event_params)

        unless @group_event.save
          render json: { error: @group_event.errors }, status: :unprocessable_entity
          return
        end

        render json: { data: @group_event }, status: :accepted
      end

      # - API to update group events
      # - DELETE api/v1/group_events/:id.json

      def destroy
        unless @group_event.destroy
          render json: { error: @group_event.errors }, status: :unprocessable_entity
          return
        end

        render json: {
          data: {
            message: 'group event deleted successfully'
          }
        }, status: :ok
      end

      private

      def find_group_event
        @group_event = current_user.group_events.find(params[:id])
      end

      def group_event_params
        params.require(:group_event).permit(GroupEvent::BASE_ATTRIBUTES)
      end
    end
  end
end
