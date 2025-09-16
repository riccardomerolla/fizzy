json.cache! card do
  json.(card, :id, :title, :status)
  json.image_url card.image.presence && url_for(card.image)

  json.golden card.golden?
  json.last_active_at card.last_active_at.utc
  json.created_at card.created_at.utc

  json.url card_url(card)

  json.collection do
    json.partial! "collections/collection", locals: { collection: card.collection }
  end

  json.stage do
    if card.stage
      json.partial! "workflows/stages/stage", stage: card.stage
    else
      nil
    end
  end

  json.creator do
    json.partial! "users/user", user: card.creator
  end
end
