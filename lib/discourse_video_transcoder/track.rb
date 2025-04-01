# frozen_string_literal: true

module ::DiscourseVideoTranscoder
  class Track
    attr_accessor :codec, :duration

    def initialize(codec:, duration:)
      @codec = codec
      @duration = duration
    end
  end
end
