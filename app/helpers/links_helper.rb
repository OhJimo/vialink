module LinksHelper
  def cta_position_class(position)
    case position
    when "left"
      "flex-start"
    when "right"
      "flex-end"
    else
      "center"
    end
  end

  def cta_overlay_style(link)
    {
      background: link.cta_color || "#2563eb",
      justify_content: cta_position_class(link.cta_position)
    }.map { |k, v| "#{k.to_s.dasherize}: #{v}" }.join("; ")
  end
end
