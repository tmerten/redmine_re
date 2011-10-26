require 'ajaxful_rating_jquery'

AjaxfulRating::StarsBuilder.class_eval do
    def link_star_tag(value, css_class)
      html = {
        :"data-method" => options[:method],
        :"data-stars" => value,
        :"data-dimension" => options[:dimension],
        :"data-size" => options[:size],
        :"data-show_user_rating" => options[:show_user_rating],
        :class => css_class,
        :title => i18n(:hover, value)
      }
      @template.link_to_remote(value,
                              {:url => options[:url].merge({:stars => value, :dimension => options[:dimension]}),
                               :method => :post},
                               html)
    end
end

# Make the css file portable
AjaxfulRating::Helpers.module_eval do
    def ajaxful_rating_style
      @axr_css ||= AjaxfulRating::CSSBuilder.new

      stylesheet_link_tag('ajaxful_rating', :plugin => "redmine_re") +
        content_tag(:style, @axr_css.to_css, :type => "text/css")
    end
end