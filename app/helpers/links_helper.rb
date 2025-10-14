module LinksHelper
  POSITION_CLASSES = {
    "left" => "flex-start",
    "right" => "flex-end",
    "center" => "center"
  }.freeze

  def cta_position_class(position)
    POSITION_CLASSES.fetch(position, "center")
  end

  def cta_overlay_style(link)
    styles = {
      background: link.cta_color.presence || DefaultAttributes::DEFAULT_CTA_COLOR,
      justify_content: cta_position_class(link.cta_position)
    }
    styles.map { |key, value| "#{key.to_s.dasherize}: #{value}" }.join("; ")
  end
end
