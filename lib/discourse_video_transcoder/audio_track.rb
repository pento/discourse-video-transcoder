# frozen_string_literal: true

module ::DiscourseVideoTranscoder
  class AudioTrack < Track
    attr_accessor :codec, :duration, :channels, :sample_rate

    def initialize(codec:, duration:, channels:, sample_rate:)
      super(codec: codec, duration: duration)

      @channels = channels
      @sample_rate = sample_rate
    end
  end
end
