module EventsHelper
  
  def markdown_text(md_text)
    # Initializes a Markdown parser
    markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)
    markdown.render(md_text).html_safe
  end
  
  def highlight(hsl_colors)
    return "" if hsl_colors.nil?
    return %Q( style="background-color: hsl(#{hsl_colors[:background]});").html_safe
  end
  
end