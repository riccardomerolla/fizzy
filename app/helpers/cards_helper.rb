module CardsHelper
  def cards_next_page_link(target, page:, filter:, fetch_on_visible: false, data: {}, **options)
    url = cards_previews_path(target: target, page: page.next_param, **filter.as_params)

    if fetch_on_visible
      data[:controller] = "#{data[:controller]} fetch-on-visible"
      data[:fetch_on_visible_url_value] = url
    end

    link_to "Load more",
      url,
      id: "#{target}-load-page-#{page.next_param}",
      data: { turbo_stream: true, **data },
      class: "btn txt-small",
      **options
  end

  def card_article_tag(card, id: dom_id(card, :ticket), **options, &block)
    classes = [
      options.delete(:class),
      ("card--golden" if card.golden?),
      ("card--doing" if card.doing?)
    ].compact.join(" ")

    tag.article \
      id: id,
      style: "--card-color: #{card.color}; view-transition-name: #{id}",
      class: classes,
      **options,
      &block
  end
end
