# frozen_string_literal: true

# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/.
#
# Copyright (c) 2018 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under the
# terms of the GNU Lesser General Public License as published by the Free Software
# Foundation; either version 3.0 of the License, or (at your option) any later
# version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
require 'jalaali'

module RecordingsHelper

  # Helper for converting BigBlueButton dates into the desired format.
  def recording_date(date)
    #I18n.l date, format: "%B %d, %Y"
    #d = date.to_parsi
    jldate = toJalaali(date.year, date.mon, date.mday)
    j2s(jldate[:jy], jldate[:jm], jldate[:jd])
    #d.strftime "%A %d %B %Y"
  end

  # Helper for converting BigBlueButton dates into a nice length string.
  def recording_length(playbacks)
    # Looping through playbacks array and returning first non-zero length value
    playbacks.each do |playback|
      length = playback[:length]
      return recording_length_string(length) unless length.zero?
    end
    # Return '< 1 min' if length values are zero
    "< 1 min"
  end

  # Prevents single images from erroring when not passed as an array.
  def safe_recording_images(images)
    Array.wrap(images)
  end

  def room_uid_from_bbb(bbb_id)
    Room.find_by(bbb_id: bbb_id)[:uid]
  end

  # returns whether recording thumbnails are enabled on the server
  def recording_thumbnails?
    Rails.configuration.recording_thumbnails
  end

  def recording_url(meeting_id)
    base = root_url.chomp("/")[/.*\//]
    url = "#{base}download/presentation/#{meeting_id}/output.webm"
    begin
      uri = URI.parse("#{base}download/presentation/#{meeting_id}/output.webm")
      req = Net::HTTP.new(uri.host, uri.port)
      req.use_ssl = true
      res = req.request_head(uri.path)
      if res.code == 200 || res.code == "200"
        url
      else
        false
      end
    rescue SocketError => e
      logger.error "Support: Error in removing room shared access: #{e}"
      #   # do the next thing
    end

  end

  private

  # Returns length of the recording as a string
  def recording_length_string(len)
    if len > 60
      "#{(len / 60).to_i} #{I18n.t('recording.h')} #{len % 60} #{I18n.t('recording.min')}"
    else
      "#{len} #{I18n.t('recording.min')}"
    end
  end
end
