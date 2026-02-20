class AnalyticsHighlightService
  def initialize(scores)
    @scores = scores
  end

  def call
    return { highest: nil, lowest: nil, closest: nil, average: 0 } if @scores.empty? #スコアがない場合は全てnil/0で返す

    values = @scores.values.map(&:to_f)
    avg = values.sum.to_f / values.size  #average

    max_range = @scores.max_by { |name, score| score }
    max_name, max_score = max_range
    max_diff = max_score - avg

    min_range = @scores.min_by { |name, score| score }
    min_name, min_score = min_range
    min_diff = min_score - avg

    closest_range = @scores.min_by { |name, score| (score - avg).abs }
    closest_name, closest_score = closest_range
    closest_diff = closest_score - avg

    {
      highest: {
        name: max_name,
        score: max_score,
        diff: max_diff
      },
      lowest: {
        name: min_name,
        score: min_score,
        diff: min_diff
      },
      closest: {
        name: closest_name,
        score: closest_score,
        diff: closest_diff
      },
      average: avg
    }
  end
end
