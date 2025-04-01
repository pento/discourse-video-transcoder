# frozen_string_literal: true

# name: discourse-video-transcoder
# about: A video transcoding plugin.
# meta_topic_id: TODO
# version: 0.0.1
# authors: pento
# url: TODO
# required_version: 2.7.0

enabled_site_setting :discourse_video_transcoder_enabled

require_relative "lib/discourse_video_transcoder/engine"

after_initialize do
  require_relative "lib/discourse_video_transcoder/extensions/upload_creator_extension"
  require_relative "lib/discourse_video_transcoder/extensions/upload_extension"

  reloadable_patch { UploadCreator.prepend(DiscourseVideoTranscoder::UploadCreatorExtension) }
  reloadable_patch { Upload.prepend(DiscourseVideoTranscoder::UploadExtension) }
end
