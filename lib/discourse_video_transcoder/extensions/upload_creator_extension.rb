# frozen_string_literal: true

module ::DiscourseVideoTranscoder
  module UploadCreatorExtension
    def create_for(user_id)
      super(user_id)
      Discourse.warn("Running our upload creator extension", {})

      if @upload.errors.empty?
        # Enqueue a transcoding job for video files
        if FileHelper.is_supported_video?(@upload.original_filename)
          Jobs.enqueue(::Jobs::DiscourseVideoTranscoder::Transcode, upload_id: @upload.id)
        end
      end

      @upload
    end
  end
end
