# frozen_string_literal: true

module ::DiscourseVideoTranscoder
  class Transcode
    attr_accessor :video, :output_path

    def initialize(video:, output_path:)
      @video = video
      @output_path = output_path
    end

    def transcode
      video_options = {
        vcodec: "libx264",
        "b:v": 1_400_000,
        coder: 1,
        trellis: 2,
        flags: "+loop",
        cmp: "+chroma",
        partitions: "+parti8x8+parti4x4+partp8x8+partp4x4+partb8x8",
        me_method: "umh",
        me_range: 16,
        rc_eq: "'blurCplx^(1-qComp)'",
        qcomp: 0.6,
        qdiff: 4,
        qmin: 10,
        qmax: 51,
        g: 250,
        keyint_min: 25,
        sc_threshold: 40,
        i_qfactor: 0.71,
        b_strategy: 2,
        bf: 3,
        refs: 4,
      }
      audio_options = { acodec: "aac", ab: 160_000, ar: 48_000, async: 1 }

      # Frame size must be divisible by 2
      width = [@video.video_track.width, 1280].min
      width -= 1 if width.odd?

      height = (width * (@video.video_track.height.to_f / @video.video_track.width.to_f)).to_i
      height -= 1 if height.odd?

      # Add a rotation filter if needed
      if @video.video_track.rotation_degrees == 90
        video_options[:vf] = "transpose=1"
      elsif @video.video_track.rotation_degrees == 180
        video_options[:vf] = "hflip,vflip"
      elsif @video.video_track.rotation_degrees == 270
        video_options[:vf] = "transpose=2"
      end

      # Deal with weird frame rates
      video_options[:r] = 30 if @video.video_track.frame_rate > 100

      options = video_options.merge(audio_options).map { |k, v| "-#{k} #{v}" }.join(" ")

      Discourse.warn("Transcoding video with options: #{options}", {})
      Discourse.warn("Video: #{@video.pretty_inspect}", {})

      cmd =
        "ffmpeg -i #{@video.file_path} -y -timelimit 28800 -threads 0 -f mp4 -hide_banner -v error -s #{width}x#{height} #{options} #{@output_path}"
      Discourse.warn("Transcoding video with command: #{cmd}", {})
      result = `#{cmd} 2>&1`
      raise "ffmpeg failed: #{result}" unless $?.success?
    end
  end
end
