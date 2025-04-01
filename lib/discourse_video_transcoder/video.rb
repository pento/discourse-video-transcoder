# frozen_string_literal: true

module ::DiscourseVideoTranscoder
  class Video
    attr_accessor :duration, :bitrate, :video_track, :audio_track, :file_path

    def initialize(duration:, bitrate:, video_track:, audio_track:, file_path:)
      @duration = duration
      @bitrate = bitrate
      @video_track = video_track
      @audio_track = audio_track
      @file_path = file_path
    end

    def self.from_file(file_path)
      cmd =
        "ffprobe #{file_path} -show_format -show_streams -output_format json -hide_banner -v error"
      Discourse.warn("ffprobe command: #{cmd}", {})
      raw = `#{cmd} 2>&1`
      raise "ffprobe failed: #{raw}" unless $?.success?
      data = JSON.parse(raw)

      video_track = nil
      audio_track = nil

      data["streams"].each do |stream|
        if stream["codec_type"] == "video"
          # Handle rotation degrees
          rotation_degrees = 0
          if stream["rotate"] && stream["rotate"].to_i >= 0 && stream["rotate"].to_i <= 360
            rotation_degrees = stream["rotate"].to_i
          else
            # Sometimes rotation is stored in EXIF data (looking at you, iPhone)
            exifdata = `exiftool -rotation #{file_path} 2>&1`
            if $?.success?
              exif_rotation = exifdata.match(/Rotation\s+:\s+(\d+)/)
              if exif_rotation && exif_rotation[1].to_i >= 0 && exif_rotation[1].to_i <= 360
                rotation_degrees = exif_rotation[1].to_i
              end
            end
          end

          video_track =
            VideoTrack.new(
              codec: stream["codec_name"],
              duration: stream["duration"].to_f,
              width: stream["width"].to_i,
              height: stream["height"].to_i,
              frame_rate: calculate_frame_rate(stream["avg_frame_rate"] || stream["r_frame_rate"]),
              frame_count: stream["nb_frames"].to_i,
              rotation_degrees: rotation_degrees,
            )
        elsif stream["codec_type"] == "audio"
          audio_track =
            AudioTrack.new(
              codec: stream["codec_name"],
              duration: stream["duration"].to_f,
              channels: stream["channels"].to_i,
              sample_rate: stream["sample_rate"].to_i,
            )
        end
      end

      Discourse.warn("Video track: #{video_track.inspect}", {})
      Discourse.warn("Audio track: #{audio_track.inspect}", {})

      return nil unless video_track && audio_track

      new(
        duration: data["format"]["duration"],
        bitrate: data["format"]["bit_rate"],
        video_track: video_track,
        audio_track: audio_track,
        file_path: file_path,
      )
    end

    def codecs
      @codecs ||=
        begin
          codecs = []
          codecs << video_track.codec if video_track
          codecs << audio_track.codec if audio_track
          codecs
        end
    end

    private

    def self.calculate_frame_rate(frame_rate)
      return 0 if frame_rate.nil?

      # Handle different formats of frame rate
      if frame_rate.include?("/")
        numerator, denominator = frame_rate.split("/").map(&:to_f)
        numerator / denominator
      elsif frame_rate.include?(":")
        numerator, denominator = frame_rate.split(":").map(&:to_f)
        numerator / denominator
      else
        frame_rate.to_f
      end
    end
  end
end
