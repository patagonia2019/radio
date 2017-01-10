json.extract! stream, :id, :name, :url_type, :station_id, :created_at, :updated_at
json.url stream_url(stream, format: :json)
