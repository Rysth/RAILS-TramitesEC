Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:5173', 'https://react-tramitesec-uxbm.onrender.com'  # Add your frontend URL

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head], 
      credentials: true,
      expose: [:Authorization]
  end
end