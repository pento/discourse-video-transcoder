# frozen_string_literal: true

module Jobs
  module DiscourseVideoTranscoder
    class Transcode < ::Jobs::Base
      def execute(args = {})
        Discourse.warn("Transcoding video with args: #{args.inspect}", {})
        @upload = Upload.find_by(id: args[:upload_id])
        return unless @upload

        video = ::DiscourseVideoTranscoder::Video.from_file(path)
        return unless video

        output_path = "/tmp/transcoded_video_#{@upload.id}.mp4"

        transcoder = ::DiscourseVideoTranscoder::Transcode.new(video:, output_path:)
        transcoder.transcode

        upload_path = Discourse.store.get_path_for("transcoded", @upload.id, @upload.sha1, ".mp4")
        output_file = File.open(output_path, "rb")
        Discourse.store.store_file(output_file, upload_path)

        @upload.transcoded = true
        @upload.save!
      end

      def path
        if local?
          Discourse.store.path_for(@upload)
        else
          Discourse.store.download!(@upload).path
        end
      end

      def local?
        !(@upload.url =~ %r{\A(https?:)?//})
      end
    end
  end
end
