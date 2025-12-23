module ApplicationHelper
  def format_duration(seconds)
    return "-" if seconds.blank? || seconds <= 0
    h = seconds / 3600
    m = (seconds % 3600) / 60
    "#{h}時間#{m}分"
  end
end
