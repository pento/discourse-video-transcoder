# frozen_string_literal: true

module ::DiscourseVideoTranscoder
  module UploadExtension
    def self.included(base)
      base.before_create :set_transcoded
    end

    def url
      if transcoded?
        return Discourse.store.get_path_for("transcoded", id, sha1, ".mp4")
      end

      super
    end

    def transcoded?
      return false if transcoded.nil?
      transcoded
    end

    private

    def set_transcoded
      self.transcoded ||= false
    end
  end
end
