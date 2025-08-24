post "/price" do
  sleep 1
  time = Time.now

  status 200
  "Toma teu preço #{time}"
end
