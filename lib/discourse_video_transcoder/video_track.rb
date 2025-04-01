# frozen_string_literal: true

module ::DiscourseVideoTranscoder
  class VideoTrack < Track
    attr_accessor :codec, :duration, :width, :height, :frame_rate, :frame_count, :rotation_degrees

    def initialize(codec:, duration:, width:, height:, frame_rate:, frame_count:, rotation_degrees:)
      super(codec: codec, duration: duration)

      @width = width
      @height = height
      @frame_rate = frame_rate
      @frame_count = frame_count
      @rotation_degrees = rotation_degrees
    end
  end
end
