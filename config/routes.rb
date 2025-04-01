# frozen_string_literal: true

DiscourseVideoTranscoder::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw do
  mount ::DiscourseVideoTranscoder::Engine, at: "video-transcode"
end
