# Seed Users
User.create(username: "John Palacios", email: "admin@test.com", password: "123456")
User.create(username: "Ericka Briones", email: "ericka.b@test.com", password: "123456")
User.create(username: "William Briones", email: "william.b@test.com", password: "123456")

# Seed Clientes with Faker data
10.times do
  Cliente.create(
    cedula: Faker::IDNumber.unique.spanish_citizen_number,
    nombres: Faker::Name.first_name,
    apellidos: Faker::Name.last_name,
    direccion: Faker::Address.street_address,
    email: Faker::Internet.email,
    active: Faker::Boolean.boolean(true_ratio: 0.8),
    user_id: User.ids.sample
  )
end
